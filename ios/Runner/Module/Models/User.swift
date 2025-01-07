struct User: Codable {
    
    var uid: String
    var nickname: String
    var avatar: String
    var diamonds: Int
    var membershipExpiryDate: Date?

    static let defaultDiamonds = 10
    
    init(uid: String, nickname: String, avatar: String, diamonds: Int = defaultDiamonds) {
        self.uid = uid
        self.nickname = nickname
        self.avatar = avatar
        self.diamonds = diamonds
    }

    var isMembershipValid: Bool {
        guard let expiryDate = membershipExpiryDate else {
            return false
        }
        return expiryDate > Date()
    }
    
    var formattedExpiryDate: String? {
        guard let expiryDate = membershipExpiryDate else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        return dateFormatter.string(from: expiryDate)
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
    
    func isVIPValid() -> Bool {
        return currentUser?.isMembershipValid ?? false
    }
    
    func updateVIPExpirationDate(_ date: Date?) {
        if var user = currentUser {
            user.membershipExpiryDate = date
            currentUser = user
        }
    }
    
    func extendMembership(by days: Int) {
        let calendar = Calendar.current
        let expiryDate: Date
        
        if let currentExpiryDate = currentUser?.membershipExpiryDate,
           currentExpiryDate > Date() {
            expiryDate = calendar.date(byAdding: .day, value: days, to: currentExpiryDate) ?? Date()
        } else {
            expiryDate = calendar.date(byAdding: .day, value: days, to: Date()) ?? Date()
        }
        
        if var user = currentUser {
            user.membershipExpiryDate = expiryDate
            currentUser = user
        }
    }
}
