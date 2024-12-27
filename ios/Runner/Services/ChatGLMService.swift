import Foundation

class ChatGLMService {
    static let shared = ChatGLMService()
    
    private let apiKey = "5053db56e9150ee366ed691459e21b65.WAm2RRwtTPSSCjoB"
    private let baseURL = "https://open.bigmodel.cn/api/paas/v4/chat/completions"
    
    private init() {}
    
    func chat(message: String) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw ChatGLMError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ChatGLMRequest(
            model: "glm-4-flash",
            messages: [
                ChatMessage(role: "user", content: message)
            ],
            temperature: 0.7,
            top_p: 0.9,
            stream: false
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            
            #if DEBUG
            print("=== Request Info ===")
            print("URL: \(baseURL)")
            print("Headers: \(request.allHTTPHeaderFields ?? [:])")
            if let bodyData = request.httpBody,
               let bodyString = String(data: bodyData, encoding: .utf8) {
                print("Body: \(bodyString)")
            }
            #endif
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            #if DEBUG
            print("\n=== Response Info ===")
            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
            }
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response Body: \(responseString)")
            }
            #endif
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ChatGLMError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let chatResponse = try JSONDecoder().decode(ChatGLMResponse.self, from: data)
                if chatResponse.success {
                    guard let responseData = chatResponse.data,
                          let firstChoice = responseData.choices.first else {
                        throw ChatGLMError.invalidResponse
                    }
                    return firstChoice.message.content
                } else {
                    throw ChatGLMError.apiError(code: chatResponse.code, message: chatResponse.msg)
                }
            case 401:
                throw ChatGLMError.unauthorized
            case 429:
                throw ChatGLMError.rateLimitExceeded
            default:
                throw ChatGLMError.httpError(statusCode: httpResponse.statusCode)
            }
        } catch let error as DecodingError {
            print("Decoding Error: \(error)")
            throw ChatGLMError.decodingError(error.localizedDescription)
        } catch {
            print("Other Error: \(error)")
            throw error
        }
    }
}

// 错误类型
enum ChatGLMError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case rateLimitExceeded
    case apiError(code: Int, message: String)
    case httpError(statusCode: Int)
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .invalidResponse:
            return "无效的响应数据"
        case .unauthorized:
            return "API密钥无效或已过期"
        case .rateLimitExceeded:
            return "超出API调用限制"
        case .apiError(_, let message):
            return message
        case .httpError(let statusCode):
            return "HTTP错误: \(statusCode)"
        case .decodingError(let message):
            return "数据解析错误: \(message)"
        }
    }
}

// 请求模型
struct ChatGLMRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let temperature: Double
    let top_p: Double
    let stream: Bool
    
    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case top_p = "top_p"
        case stream
    }
}

struct ChatMessage: Codable {
    let role: String
    let content: String
}

// 响应模型
struct ChatGLMResponse: Codable {
    let id: String
    let created: Int
    let model: String
    let choices: [ChatGLMChoice]
    let usage: ChatGLMUsage
    
    // 为了兼容之前的代码，添加计算属性
    var success: Bool { true }
    var code: Int { 200 }
    var msg: String { "" }
    var data: ChatGLMData? {
        return ChatGLMData(
            request_id: id,
            task_id: id,
            task_status: "SUCCESS",
            choices: choices,
            usage: usage
        )
    }
}

struct ChatGLMChoice: Codable {
    let index: Int
    let message: ChatMessage
    let finish_reason: String?
}

struct ChatGLMUsage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}

// ChatGLMData 结构体保留用于兼容性
struct ChatGLMData: Codable {
    let request_id: String
    let task_id: String
    let task_status: String
    let choices: [ChatGLMChoice]
    let usage: ChatGLMUsage
}
