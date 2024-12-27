import UIKit

class BaseViewController: UIViewController {
    
    var hideNavigationBar = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(hideNavigationBar, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBaseUI()
        setupUI()
    }
    
    private func setupBaseUI() {
        // 设置深色主题基础样式
        view.backgroundColor = .black
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        
        if #available(iOS 13.0, *) {
            // 设置状态栏为浅色
            overrideUserInterfaceStyle = .dark
        }
    }
    
    // 子类可重写此方法来设置UI
    func setupUI() {}
} 
