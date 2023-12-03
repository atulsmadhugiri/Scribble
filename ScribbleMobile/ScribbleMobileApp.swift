import SwiftData
import SwiftUI

@main
struct ScribbleMobileApp: App {
  var modelContainer = {
    do {
      return try ModelContainer(for: GeneratedImage.self)
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  var body: some Scene {
    WindowGroup {
      MainView()
    }
    .modelContainer(modelContainer)
  }
}
