import UIKit
import Flutter
import AppTrackingTransparency

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
          if #available(iOS 14, *) {
              ATTrackingManager.requestTrackingAuthorization { status in
                  // Handle tracking authorization status
              }
          }
      }

      self.window = UIWindow.init(frame: UIScreen.main.bounds)
      self.window?.backgroundColor = .white
      self.window?.makeKeyAndVisible()

      // 判断是否首次启动
      if UserDefaults.hasLaunched {
          self.window?.rootViewController = MainTabBarController()
      } else {
          self.window?.rootViewController = FirstLaunchViewController()
      }
      
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
