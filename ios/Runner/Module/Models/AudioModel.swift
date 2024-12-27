import Foundation

struct AudioModel: Codable {
    /// 唯一标识符
    let id: String
    
    /// 音频标题
    let title: String
    
    /// 艺术家名称
    let artist: String
    
    /// 音频描述
    let description: String
    
    /// 音频时长（秒）
    let duration: Double
    
    /// 本地文件路径
    let localPath: String
    
    /// 封面图片名称
    let coverImageName: String
    
    /// 背景图片
    let bgImageName: String
    
    /// 初始化方法
    init(id: String,
         title: String,
         artist: String,
         description: String,
         duration: Double,
         localPath: String,
         coverImageName: String,
         bgImageName: String) {
        self.id = id
        self.title = title
        self.artist = artist
        self.description = description
        self.duration = duration
        self.localPath = localPath
        self.coverImageName = coverImageName
        self.bgImageName = bgImageName
    }
}

// MARK: - 便利方法
extension AudioModel {
    /// 格式化的时长字符串
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
  
    /// 完整的本地文件URL
    var localURL: URL? {
        // 首先检查 Bundle 中的资源
        if let bundlePath = Bundle.main.path(forResource: localPath, ofType: nil) {
            return URL(fileURLWithPath: bundlePath)
        }
        
        // 如果 Bundle 中没有，则检查 Documents 目录
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsPath.appendingPathComponent(localPath)
    }
}

// MARK: - Equatable
extension AudioModel: Equatable {
    static func == (lhs: AudioModel, rhs: AudioModel) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - 示例数据
extension AudioModel {
    static var mockData: AudioModel {
        return AudioModel(
            id: "1",
            title: "YELLOW",
            artist: "神山羊",
            description: "午休时刻，音乐和咖啡缺一不可",
            duration: 178,
            localPath: "video_01.mp3",
            coverImageName: "yellow_cover",
            bgImageName: ""
        )
    }
} 
