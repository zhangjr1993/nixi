import Foundation

struct CategorySection {
    let title: String
    var avatars: [AIAvatar]
    
    static let categories = ["养鱼", "万圣节", "双11", "音乐", "美食", "旅游", "宠物", "历史"]
}

struct AIAvatarsResponse: Codable {
    let avatars: [AIAvatar]
} 
