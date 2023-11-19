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
    apiKey: Secrets.OPENAI_API_KEY)

  let jsonDecoder = JSONDecoder()
  let imageGenerationReponse = try jsonDecoder.decode(ImageGenerationResponse.self, from: data)

  return imageGenerationReponse

}
