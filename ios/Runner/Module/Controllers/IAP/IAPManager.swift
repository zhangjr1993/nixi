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
        // 如果已经有缓存的商品信息，直接返回
        if !self.products.isEmpty {
            return self.products
        }
        
        let productIds = Set(IAPProduct.allProducts.map { $0.productId })
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = SKProductsRequest(productIdentifiers: productIds)
            request.delegate = self
            
            self.productsCompletion = { result in
                switch result {
                case .success(let product):
                    // 这里不应该只返回一个商品
                    if !self.products.isEmpty {
                        continuation.resume(returning: self.products)
                    } else {
                        continuation.resume(throwing: IAPError.productNotFound)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            request.start()
        }
    }
    
    func startPayment(productId: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.purchaseCompletion = { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            // 直接创建支付，因为商品信息已经在之前验证过了
            if let product = self.products.first(where: { $0.productIdentifier == productId }) {
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(payment)
            } else {
                self.purchaseCompletion?(.failure(.productNotFound))
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
            if !response.products.isEmpty {
                self.products = response.products
                self.productsCompletion?(.success(response.products[0])) // 这里传任意产品都可以，因为我们在 completion 中会返回 self.products
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
