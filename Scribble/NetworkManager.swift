import Foundation

struct NetworkManager {

  static func sendOpenAIRequest<T: Codable>(to url: URL, with body: T) async throws -> Data {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(Secrets.OPENAI_API_KEY)", forHTTPHeaderField: "Authorization")

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
