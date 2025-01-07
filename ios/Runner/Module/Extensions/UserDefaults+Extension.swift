import Foundation

extension UserDefaults {
    private enum Keys {
        static let hasLaunched = "hasLaunched"
        static let showAudioAlert = "showAudioAlert"
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
    
    static var showAudioAlert: Bool {
        get {
            return standard.bool(forKey: Keys.showAudioAlert)
        }
        set {
            standard.set(newValue, forKey: Keys.showAudioAlert)
            standard.synchronize()
        }
    }
}
