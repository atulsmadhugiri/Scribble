import Foundation

enum ImageModel: String, Codable {
  case dalle2 = "dall-e-2"
  case dalle3 = "dall-e-3"
}

enum ImageQuality: String, Codable {
  case standard = "standard"
  case hd = "hd"
}

enum ImageSize: String, Codable {
  case small = "256x256"
  case medium = "512x512"
  case large = "1024x1024"
}

struct ImageGenerationRequest: Codable {
  let model: ImageModel
  let prompt: String
  let size: ImageSize
  let quality: ImageQuality
  static let n = 1
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
    size: .large,
    quality: .standard)

  let data = try await NetworkManager.sendRequest(
    to: URL(string: "https://api.openai.com/v1/images/generations")!,
    with: imageGenerationRequest)

  let jsonDecoder = JSONDecoder()
  let imageGenerationReponse = try jsonDecoder.decode(ImageGenerationResponse.self, from: data)

  return imageGenerationReponse

}
