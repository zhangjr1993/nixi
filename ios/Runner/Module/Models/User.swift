struct User: Codable {
    var uid: String
    var nickname: String
    var avatar: String
    var diamonds: Int
    
    static let defaultDiamonds = 10
    
    init(uid: String, nickname: String, avatar: String, diamonds: Int = defaultDiamonds) {
        self.uid = uid
        self.nickname = nickname
        self.avatar = avatar
        self.diamonds = diamonds
    }
}

class UserManager {
    static let shared = UserManager()
    private let userDefaultsKey = "currentUser"
    
    private(set) var currentUser: User? {
        didSet {
            saveUser()
        }
    }
    
    private init() {
        loadUser()
    }
    
    private func loadUser() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
        }
    }
    
    private func saveUser() {
        if let user = currentUser,
           let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    func updateDiamonds(_ newAmount: Int) {
        currentUser?.diamonds = newAmount
    }
    
    func createNewUser(uid: String, nickname: String, avatar: String) {
        currentUser = User(uid: uid, nickname: nickname, avatar: avatar)
    }
} 