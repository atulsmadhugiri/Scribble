import Foundation
import SwiftData

@Model
final class GeneratedImage: Identifiable {
  var created: Int
  var revised_prompt: String
  var url: String
  var timeElapsed: Double?

  init(created: Int, revised_prompt: String, url: String, timeElapsed: Double?) {
    self.created = created
    self.revised_prompt = revised_prompt
    self.url = url
    self.timeElapsed = timeElapsed
  }
}
