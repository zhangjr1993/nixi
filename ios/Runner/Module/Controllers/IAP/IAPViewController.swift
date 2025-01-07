import UIKit
import StoreKit

class IAPViewController: UIViewController {
    // MARK: - Properties
    private let buttonTitle = "立即充值"
    private let processingTitle = "处理中..."
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .medium)
        activity.color = .white
        activity.hidesWhenStopped = true
        return activity
    }()
    
    private var isProcessingPayment = false {
        didSet {
            updatePurchaseButtonState()
        }
    }
    
    private var selectedProduct: IAPProduct? {
        didSet {
            updatePurchaseButtonState()
        }
    }
    
    private lazy var membershipLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = .black
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        table.register(IAPProductCell.self, forCellReuseIdentifier: "IAPProductCell")
        table.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 100, right: 0)
        // 允许选中
        table.allowsSelection = true
        return table
    }()
    
    private lazy var purchaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(buttonTitle, for: .normal)
        button.setTitle(buttonTitle, for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.6), for: .disabled)
        button.backgroundColor = .systemBlue.withAlphaComponent(0.5)
        button.layer.cornerRadius = 25
        button.isEnabled = false
        button.addTarget(self, action: #selector(purchaseButtonTapped), for: .touchUpInside)
        
        // 添加loadingIndicator
        button.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: button.titleLabel!.leadingAnchor, constant: -8)
        ])
        
        return button
    }()
    
    private lazy var balanceView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15)
        label.text = "当前余额："
        return label
    }()
    
    private lazy var diamondsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 20, weight: .bold)
        if let diamonds = UserManager.shared.currentUser?.diamonds {
            label.text = "\(diamonds)钻石"
        }
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // 添加通知观察者
        NotificationCenter.default.addObserver(self, 
                                            selector: #selector(handlePurchaseSuccess), 
                                            name: .IAPPurchaseSuccess, 
                                            object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "钻石充值"
        view.backgroundColor = .black
        
        view.addSubview(balanceView)
        balanceView.addSubview(balanceLabel)
        balanceView.addSubview(diamondsLabel)
        balanceView.addSubview(membershipLabel)
        view.addSubview(tableView)
        view.addSubview(purchaseButton)
        
        balanceView.translatesAutoresizingMaskIntoConstraints = false
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        diamondsLabel.translatesAutoresizingMaskIntoConstraints = false
        membershipLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        purchaseButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            balanceView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            balanceView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            balanceView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            balanceView.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),
            
            balanceLabel.topAnchor.constraint(equalTo: balanceView.topAnchor, constant: 16),
            balanceLabel.leadingAnchor.constraint(equalTo: balanceView.leadingAnchor, constant: 16),
            
            diamondsLabel.centerYAnchor.constraint(equalTo: balanceLabel.centerYAnchor),
            diamondsLabel.leadingAnchor.constraint(equalTo: balanceLabel.trailingAnchor, constant: 8),
            
            membershipLabel.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 12),
            membershipLabel.leadingAnchor.constraint(equalTo: balanceView.leadingAnchor, constant: 16),
            membershipLabel.trailingAnchor.constraint(equalTo: balanceView.trailingAnchor, constant: -16),
            membershipLabel.bottomAnchor.constraint(equalTo: balanceView.bottomAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: balanceView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            purchaseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            purchaseButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            purchaseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            purchaseButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        updateMembershipStatus()
    }
    
    
    
    @objc private func purchaseButtonTapped() {
        guard let product = selectedProduct, !isProcessingPayment else { return }
        
        // 开始购买，设置状态
        isProcessingPayment = true
        
        Task {
            do {
                // 先获取商品信息
                let products = try await IAPManager.shared.loadProducts()
                guard let skProduct = products.first(where: { $0.productIdentifier == product.productId }) else {
                    throw IAPError.productNotFound
                }
                
                // 显示确认购买弹窗
                let shouldProceed = await showPurchaseConfirmation(for: skProduct)
                guard shouldProceed else {
                    isProcessingPayment = false
                    return
                }
                
                // 商品信息获取成功后开始购买
                try await IAPManager.shared.startPayment(productId: product.productId)
                // 购买成功后会通过通知更新UI
            } catch let error as IAPError {
                // 处理具体的错误
                handlePurchaseFailure(error: error)
            } catch {
                // 处理其他错误
                handlePurchaseFailure(error: IAPError.unknown)
            }
        }
    }
    
    // 添加确认购买的方法
    private func showPurchaseConfirmation(for product: SKProduct) async -> Bool {
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.locale = product.priceLocale
                let price = formatter.string(from: product.price) ?? "\(product.price)"
                
                let alert = UIAlertController(
                    title: "确认购买",
                    message: "您确定要购买 \(product.localizedTitle) 吗？价格：\(price)",
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "取消", style: .cancel) { _ in
                    continuation.resume(returning: false)
                })
                
                alert.addAction(UIAlertAction(title: "确认", style: .default) { _ in
                    continuation.resume(returning: true)
                })
                
                self.present(alert, animated: true)
            }
        }
    }
    
    @objc private func handlePurchaseSuccess() {
        // 更新钻石余额显示
        if let diamonds = UserManager.shared.currentUser?.diamonds {
            diamondsLabel.text = "\(diamonds)钻石"
        }
        
        // 处理会员有效期
        if let product = selectedProduct {
            switch product.productId {
            case "com.nixi.mf.zuanshi88", "com.nixi.m.zuanshi98":
                UserManager.shared.extendMembership(by: 30)
            case "com.nixi.m.zuanshi268":
                UserManager.shared.extendMembership(by: 90)
            default:
                break
            }
        }
        
        // 更新会员状态显示
        updateMembershipStatus()
        
        // 重置选中状态
        selectedProduct = nil
        isProcessingPayment = false
        
        // 刷新所有可见的单元格以更新选中状态
        tableView.visibleCells.forEach { cell in
            if let productCell = cell as? IAPProductCell {
                productCell.setSelected(false, animated: true)
            }
        }
        
         
        
        // 显示成功提示
        showAlert(title: "购买成功", message: "钻石已到账")
    }
    
    private func handlePurchaseFailure(error: IAPError) {
        DispatchQueue.main.async {
            self.isProcessingPayment = false
            self.showAlert(title: "购买失败", message: error.localizedDescription)
        }
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    private func showLoadingIndicator() {
        loadingIndicator.startAnimating()
        purchaseButton.setTitle("  \(processingTitle)", for: .normal)
        purchaseButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    
    private func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
        purchaseButton.setTitle(buttonTitle, for: .normal)
        purchaseButton.setTitle(buttonTitle, for: .disabled)
        purchaseButton.titleEdgeInsets = .zero
    }
    
    // 添加新的方法来统一处理按钮状态
    private func updatePurchaseButtonState() {
        purchaseButton.isEnabled = !isProcessingPayment && selectedProduct != nil
        
        if isProcessingPayment {
            showLoadingIndicator()
        } else {
            hideLoadingIndicator()
        }
        
        purchaseButton.backgroundColor = selectedProduct != nil && !isProcessingPayment ? 
            .systemBlue : .systemBlue.withAlphaComponent(0.5)
    }
    
    private func updateMembershipStatus() {
        if let user = UserManager.shared.currentUser {
            if let expiryDate = user.membershipExpiryDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy年MM月dd日"
                membershipLabel.text = "会员有效期至 \(dateFormatter.string(from: expiryDate))"
            } else {
                membershipLabel.text = "开通会员后，有效期内无限畅聊"
            }
        }
    }
}

// MARK: - UITableViewDelegate & DataSource
extension IAPViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return IAPProduct.allProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IAPProductCell", for: indexPath) as! IAPProductCell
        let product = IAPProduct.allProducts[indexPath.row]
        
        cell.configure(with: product)
        
        // 设置选中状态
        cell.setSelected(product.productId == selectedProduct?.productId, animated: false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 更新选中状态
        let product = IAPProduct.allProducts[indexPath.row]
        
        // 如果点击已选中的项目，取消选中
        if product.productId == selectedProduct?.productId {
            selectedProduct = nil
            purchaseButton.backgroundColor = .systemBlue.withAlphaComponent(0.5)
            purchaseButton.isEnabled = false
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            selectedProduct = product
            purchaseButton.backgroundColor = .systemBlue
            purchaseButton.isEnabled = true
        }
        
        // 刷新所有可见的单元格以更新选中状态
        tableView.visibleCells.forEach { cell in
            if let productCell = cell as? IAPProductCell,
               let cellIndexPath = tableView.indexPath(for: cell) {
                let cellProduct = IAPProduct.allProducts[cellIndexPath.row]
                productCell.setSelected(cellProduct.productId == selectedProduct?.productId, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
} 
