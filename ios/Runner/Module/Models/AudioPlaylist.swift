import Foundation

struct AudioPlaylist {
    private(set) var audioList: [AudioModel]
    private(set) var currentIndex: Int
    
    init() {
        self.audioList = []
        self.currentIndex = 0
        loadAudioList()
        
        // 打印调试信息
        print("AudioPlaylist initialized with \(audioList.count) items")
    }
    
    private mutating func loadAudioList() {
        // 1. 检查文件路径
        guard let path = Bundle.main.path(forResource: "VideoResource", ofType: "geojson") else {
            print("❌ VideoResource.geojson file not found in bundle")
            return
        }
        print("✅ Found geojson file at path: \(path)")
        
        do {
            // 2. 读取数据
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            print("✅ Successfully read data from file, size: \(data.count) bytes")
            
            // 3. 直接解析为数组
            guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                print("❌ Failed to parse JSON array")
                return
            }
            print("✅ Successfully parsed JSON array with \(jsonArray.count) items")
            
            // 4. 解析每个音频项
            audioList = jsonArray.compactMap { item -> AudioModel? in
                guard let id = item["id"] as? String,
                      let coverImageName = item["coverImageName"] as? String,
                      let duration = item["duration"] as? Double,
                      let title = item["title"] as? String,
                      let artist = item["artist"] as? String,
                      let description = item["description"] as? String,
                      let localPath = item["localPath"] as? String,
                      let bgImgName = item["bgImageName"] as? String else {
                    print("❌ Missing required properties in item: \(item)")
                    return nil
                }
                
                let audioModel = AudioModel(
                    id: id,
                    title: title,
                    artist: artist,
                    description: description,
                    duration: duration,
                    localPath: "\(localPath).mp3", // 添加 .mp3 扩展名
                    coverImageName: coverImageName,
                    bgImageName: bgImgName
                )
                
                print("✅ Successfully created AudioModel for: \(title)")
                return audioModel
            }
            
            print("✅ Final audioList count: \(audioList.count)")
            
        } catch {
            print("❌ Error loading audio list: \(error)")
        }
    }
    
    mutating func nextAudio() -> AudioModel? {
        guard !audioList.isEmpty else { return nil }
        currentIndex = (currentIndex + 1) % audioList.count
        return audioList[currentIndex]
    }
    
    mutating func previousAudio() -> AudioModel? {
        guard !audioList.isEmpty else { return nil }
        currentIndex = (currentIndex - 1 + audioList.count) % audioList.count
        return audioList[currentIndex]
    }
    
    func getCurrentAudio() -> AudioModel? {
        guard !audioList.isEmpty else { return nil }
        return audioList[currentIndex]
    }
} 
