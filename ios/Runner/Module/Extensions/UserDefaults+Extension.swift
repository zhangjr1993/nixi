import Foundation

extension UserDefaults {
    private enum Keys {
        static let hasLaunched = "hasLaunched"
    }
    
    static var hasLaunched: Bool {
        get {
            return standard.bool(forKey: Keys.hasLaunched)
        }
        set {
            standard.set(newValue, forKey: Keys.hasLaunched)
            standard.synchronize()
        }
    }
} 