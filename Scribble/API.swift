import Foundation

struct NetworkManager {

  static func sendRequest<T: Codable>(to url: URL, with body: T, apiKey: String) async throws
    -> Data
  {

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

    request.httpBody = try JSONEncoder().encode(body)

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse,
      (200...299).contains(httpResponse.statusCode)
    else {
      throw URLError(.badServerResponse)
    }

    return data
  }

}

@propertyWrapper
struct EnvironmentVariable {
  let key: String
  var wrappedValue: String {
    return ProcessInfo.processInfo.environment[key] ?? ""
  }
}

struct Environment {
  @EnvironmentVariable(key: "OPENAI_API_KEY") static var apiKey: String
}

struct Message: Codable {
  let role: String
  let content: String
}

struct ChatRequest: Codable {
  let model: String
  let messages: [Message]
  let temperature: Double
}

enum ImageModel: String, Codable {
  case dalle2 = "dall-e-2"
  case dalle3 = "dall-e-3"
}

enum ImageQuality: String, Codable {
  case standard = "standard"
  case hd = "hd"
}
struct ImageGenerationRequest: Codable {
  let model: ImageModel
  let prompt: String
  let size: String
  let quality: ImageQuality
  let n: Int
}

func performChatRequest() async throws -> String {

  let chatRequest = ChatRequest(
    model: "gpt-3.5-turbo",
    messages: [
      Message(role: "user", content: "Write a Hello World in Swift and explain how it works")
    ],
    temperature: 0.7)

  let data = try await NetworkManager.sendRequest(
    to: URL(string: "https://api.openai.com/v1/chat/completions")!,
    with: chatRequest,
    apiKey: Environment.apiKey)

  return String(decoding: data, as: UTF8.self)

}

struct ImageGenerationResponseData: Decodable {
  let revised_prompt: String
  let url: String
}
struct ImageGenerationResponse: Decodable {
  let created: Int
  let data: [ImageGenerationResponseData]
}

func performImageGenerationRequest(prompt: String) async throws -> ImageGenerationResponse {

  let imageGenerationRequest = ImageGenerationRequest(
    model: .dalle3,
    prompt: prompt,
    size: "1024x1024",
    quality: .standard,
    n: 1)

  let data = try await NetworkManager.sendRequest(
    to: URL(string: "https://api.openai.com/v1/images/generations")!,
    with: imageGenerationRequest,
    apiKey: Environment.apiKey)

  let jsonDecoder = JSONDecoder()
  let imageGenerationReponse = try jsonDecoder.decode(ImageGenerationResponse.self, from: data)

  return imageGenerationReponse

}
