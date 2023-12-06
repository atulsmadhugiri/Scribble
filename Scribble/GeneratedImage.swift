import Foundation
import SwiftData

@Model
final class GeneratedImage: Identifiable {
  let created: Int = 0
  let revised_prompt: String = ""
  let url: String = ""
  let timeElapsed: Double?

  init(created: Int, revised_prompt: String, url: String, timeElapsed: Double?) {
    self.created = created
    self.revised_prompt = revised_prompt
    self.url = url
    self.timeElapsed = timeElapsed
  }
}
