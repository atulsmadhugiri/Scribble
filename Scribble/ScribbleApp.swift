import SwiftData
import SwiftUI

@main
struct ScribbleApp: App {
  var modelContainer = {
    do {
      return try ModelContainer(for: GeneratedImage.self)
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  var body: some Scene {
    MenuBarExtra("ScribbleBar", systemImage: "paintbrush.fill") {
      MainView().modelContainer(modelContainer)
    }.menuBarExtraStyle(.window)
  }
}
