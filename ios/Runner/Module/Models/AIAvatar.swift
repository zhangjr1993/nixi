struct AIAvatar: Codable {
    let id: String
    let name: String
    let avatarImageName: String
    let profession: String
    let age: Int
    let backgroundImageName: String
    let personalities: [String]
    let gender: Gender
    let backstory: String
    
    enum Gender: String, Codable {
        case male = "male"
        case female = "female"
        case other = "other"
        
        var localizedString: String {
            switch self {
            case .male: return "男"
            case .female: return "女"
            case .other: return "其他"
            }
        }
    }
} 