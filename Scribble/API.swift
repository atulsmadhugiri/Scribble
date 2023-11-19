import Foundation

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
    with: imageGenerationRequest)

  let jsonDecoder = JSONDecoder()
  let imageGenerationReponse = try jsonDecoder.decode(ImageGenerationResponse.self, from: data)

  return imageGenerationReponse

}
