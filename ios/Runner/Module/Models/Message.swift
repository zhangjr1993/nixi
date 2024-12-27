import Foundation

struct Message {
    enum MessageType {
        case sent
        case received
    }
    
    let id: String
    let content: String
    let type: MessageType
    let timestamp: Date
    
    init(content: String, type: MessageType) {
        self.id = "1"
        self.content = content
        self.type = type
        self.timestamp = Date()
    }
} 
