import UIKit

class MainTabBarController: UITabBarController {
    
    // MARK: - Properties
    private let selectedColor = UIColor(hex: "F2F4F6")
    private let normalColor = UIColor(hex: "F2F4F6").withAlphaComponent(0.6)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        setupTabBarAppearance()
        setupDefaultUser()
    }
    
    // MARK: - Setup
    internal func setupViewControllers() {
        let homeVC = HomeViewController()
        let messageVC = MessageViewController()
        let squareVC = SquareViewController()
        let profileVC = ProfileViewController()
        
        homeVC.tabBarItem = createTabBarItem(
            title: "首页",
            normalImage: "btn_tab_home_nor",
            selectedImage: "btn_tab_home_pre"
        )
        
        messageVC.tabBarItem = createTabBarItem(
            title: "消息",
            normalImage: "btn_tab_message_nor",
            selectedImage: "btn_tab_message_pre"
        )
        
        squareVC.tabBarItem = createTabBarItem(
            title: "圈子",
            normalImage: "btn_tab_draw_nor",
            selectedImage: "btn_tab_draw_pre"
        )
        
        profileVC.tabBarItem = createTabBarItem(
            title: "我的",
            normalImage: "btn_tab_me_nor",
            selectedImage: "btn_tab_me_pre"
        )
        
        // 使用导航控制器包装每个根控制器
        let controllers = [homeVC, messageVC, squareVC, profileVC].map { 
            BaseNavigationController(rootViewController: $0)
        }
        
        setViewControllers(controllers, animated: false)
        delegate = self
    }
    
    private func createTabBarItem(title: String, normalImage: String, selectedImage: String) -> UITabBarItem {
        let item = UITabBarItem(
            title: title,
            image: UIImage(named: normalImage)?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: selectedImage)?.withRenderingMode(.alwaysTemplate)
        )
        return item
    }
    
    internal func setupTabBarAppearance() {
        // 设置TabBar的外观
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            // 设置TabBar背景色为黑色
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            
            // 设置文字颜色
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: normalColor
            ]
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: selectedColor
            ]
            
            // 设置图片颜色
            appearance.stackedLayoutAppearance.normal.iconColor = normalColor
            appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
            
            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        } else {
            // iOS 13以下的适配
            tabBar.barTintColor = .black
            tabBar.tintColor = selectedColor
            tabBar.unselectedItemTintColor = normalColor
            
            UITabBarItem.appearance().setTitleTextAttributes([
                .foregroundColor: normalColor
            ], for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes([
                .foregroundColor: selectedColor
            ], for: .selected)
        }
    }
    
    private func setupDefaultUser() {
        // 如果当前没有用户，创建默认用户
        if UserManager.shared.currentUser == nil {
            UserManager.shared.createNewUser(
                uid: "100000",
                nickname: "非凡大师",
                avatar: "default_avatar"
            )
        }
    }
}

// MARK: - UIColor Extension
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

// MARK: - UITabBarControllerDelegate
extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // 确保是导航控制器
        guard let navigationController = viewController as? UINavigationController else { return }
        
        // 确保是首页控制器
        guard let homeViewController = navigationController.viewControllers.first as? HomeViewController else { return }
        
        // 如果当前已经在首页标签，并且是重复点击
        if selectedIndex == 0 && navigationController.viewControllers.count == 1 {
            homeViewController.showLoadingAndFetchData()
        }
    }
} 
