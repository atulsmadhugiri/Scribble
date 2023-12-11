import SwiftUI

struct RootView: View {
  var body: some View {
    TabView {
      ImageCreationView().tabItem {
        Label("Create", systemImage: "paintbrush")
      }
      ImageBrowsingView().tabItem {
        Label("Explore", systemImage: "photo")
      }
    }
  }
}

#Preview {
  RootView()
}
