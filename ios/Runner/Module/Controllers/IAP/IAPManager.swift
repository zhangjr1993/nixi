import StoreKit

enum IAPError: Error {
    case productNotFound
    case purchaseFailed
    case paymentInvalid
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .productNotFound:
            return "商品信息获取失败"
        case .purchaseFailed:
            return "购买失败"
        case .paymentInvalid:
            return "支付验证失败"
        case .unknown:
            return "未知错误"
        }
    }
}

extension Notification.Name {
    static let IAPPurchaseSuccess = Notification.Name("IAPPurchaseSuccess")
    static let UserDiamondsDidUpdate = Notification.Name("UserDiamondsDidUpdate")
}

class IAPManager: NSObject {
    static let shared = IAPManager()
    
    private var products: [SKProduct] = []
    private var productsCompletion: ((Result<SKProduct, IAPError>) -> Void)?
    private var purchaseCompletion: ((Result<Bool, IAPError>) -> Void)?
    
    private override init() {
        super.init()
        // 设置交易观察者
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func loadProducts() async throws -> [SKProduct] {
        let productIds = Set(IAPProduct.allProducts.map { $0.productId })
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = SKProductsRequest(productIdentifiers: productIds)
            request.delegate = self
            
            self.productsCompletion = { result in
                switch result {
                case .success(let product):
                    continuation.resume(returning: [product])
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            request.start()
        }
    }
    
    func startPayment(productId: String) async throws {
        // 1. 先检查是否有未完成的交易
        return try await withCheckedThrowingContinuation { continuation in
            self.purchaseCompletion = { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            // 先尝试恢复购买
            SKPaymentQueue.default().restoreCompletedTransactions()
            
            // 在恢复完成后，如果没有相关交易，则创建新的购买
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let self = self else { return }
                
                // 查找对应的SKProduct
                if let product = self.products.first(where: { $0.productIdentifier == productId }) {
                    // 创建新的购买
                    let payment = SKPayment(product: product)
                    SKPaymentQueue.default().add(payment)
                } else {
                    // 如果找不到产品，重新加载产品信息
                    Task {
                        do {
                            let products = try await self.loadProducts()
                            if let product = products.first(where: { $0.productIdentifier == productId }) {
                                let payment = SKPayment(product: product)
                                SKPaymentQueue.default().add(payment)
                            } else {
                                self.purchaseCompletion?(.failure(.productNotFound))
                            }
                        } catch {
                            self.purchaseCompletion?(.failure(.unknown))
                        }
                    }
                }
            }
        }
    }
    
    private func handlePurchaseSuccess(for productId: String) {
        // 根据商品ID更新用户钻石数量
        guard let product = IAPProduct.allProducts.first(where: { $0.productId == productId }),
              let diamonds = product.diamonds,
              let currentUser = UserManager.shared.currentUser else {
            return
        }
        
        // 更新用户钻石余额
        UserManager.shared.updateDiamonds(currentUser.diamonds + diamonds)
        
        // 发送购买成功通知
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .IAPPurchaseSuccess, object: nil)
        }
    }
}

// MARK: - SKProductsRequestDelegate
extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            if let product = response.products.first {
                self.products = response.products
                self.productsCompletion?(.success(product))
            } else {
                self.productsCompletion?(.failure(.productNotFound))
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.productsCompletion?(.failure(.unknown))
        }
    }
}

// MARK: - SKPaymentTransactionObserver
extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                // 购买成功
                handlePurchaseSuccess(for: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                purchaseCompletion?(.success(true))
                
            case .failed:
                // 购买失败
                queue.finishTransaction(transaction)
                purchaseCompletion?(.failure(.purchaseFailed))
                
            case .restored:
                // 恢复购买
                handlePurchaseSuccess(for: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                purchaseCompletion?(.success(true))
                
            case .deferred, .purchasing:
                break
            @unknown default:
                break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        // 恢复购买完成，如果没有恢复任何交易，会继续创建新的购买
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        // 恢复购买失败，继续创建新的购买
        purchaseCompletion?(.failure(.unknown))
    }
}
