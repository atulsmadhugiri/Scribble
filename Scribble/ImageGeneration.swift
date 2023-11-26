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

enum ImageResponseFormat: String, Codable {
  case url = "url"
  case base64 = "b64_json"
}

struct ImageGenerationRequest: Codable {
  let model: ImageModel
  let prompt: String
  let size: ImageSize
  let quality: ImageQuality
  let response_format: ImageResponseFormat
  static let n = 1
}

struct ImageGenerationResponseData: Codable {
  let revised_prompt: String?
  let b64_json: String
}

struct ImageGenerationResponse: Codable {
  let created: Int
  let data: [ImageGenerationResponseData]
}

struct ImageGeneration {
  let created: Int
  let revised_prompt: String
  let url: String
}

func performImageGenerationRequest(
  prompt: String,
  model: ImageModel = .dalle3,
  quality: ImageQuality = .standard
) async throws -> ImageGeneration {

  let imageGenerationRequest = ImageGenerationRequest(
    model: model,
    prompt: prompt,
    size: .large,
    quality: quality,
    response_format: .base64
  )

  let data = try await NetworkManager.sendOpenAIRequest(
    to: URL(string: "https://api.openai.com/v1/images/generations")!,
    with: imageGenerationRequest)

  let jsonDecoder = JSONDecoder()
  let imageGenerationReponse = try jsonDecoder.decode(ImageGenerationResponse.self, from: data)

  let temporaryDirectory = URL.homeDirectory.appending(
    path: ".scribble",
    directoryHint: .isDirectory)

  guard let data = Data(base64Encoded: imageGenerationReponse.data.first!.b64_json) else {
    throw NSError()
  }

  try FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
  let filePath = temporaryDirectory.appending(component: "\(imageGenerationReponse.created).png")
  try data.write(to: filePath)

  return ImageGeneration(
    created: imageGenerationReponse.created,
    revised_prompt: imageGenerationReponse.data.first!.revised_prompt ?? prompt,
    url: filePath.absoluteString)
}
