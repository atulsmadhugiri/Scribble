import Foundation
import SwiftData

@Model
final class GeneratedImage: Identifiable {
  let created: Int
  let revised_prompt: String
  let url: String

  init(created: Int, revised_prompt: String, url: String) {
    self.created = created
    self.revised_prompt = revised_prompt
    self.url = url
  }
}
