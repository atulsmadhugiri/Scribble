import SwiftData
import SwiftUI

struct ImageBrowsingView: View {
  @Query(sort: \GeneratedImage.created, order: .reverse) var entries: [GeneratedImage]

  @State private var searchTerm = ""
  var filteredEntries: [GeneratedImage] {
    guard !searchTerm.isEmpty else { return entries }
    return entries.filter { $0.revised_prompt.localizedCaseInsensitiveContains(searchTerm) }
  }

  var body: some View {
    NavigationView {
      List {
        ForEach(filteredEntries, id: \.id) { entry in
          HStack {
            AsyncImage(url: URL.documentsDirectory.appending(component: entry.url)) { image in
              image.interpolation(.none).resizable().scaledToFit().cornerRadius(8).frame(
                width: 100, height: 100
              ).transition(.opacity.animation(.default))
            } placeholder: {
              ZStack {
                ProgressView().progressViewStyle(CircularProgressViewStyle())
                Color.gray.opacity(0.1).cornerRadius(8).frame(width: 100, height: 100)
              }
            }
            Text(entry.revised_prompt).font(.footnote).lineLimit(6)
          }
        }
      }.searchable(text: $searchTerm, placement: .automatic, prompt: "")
        .listStyle(.plain)
        .navigationBarTitle("Image Generations", displayMode: .inline)
    }
  }
}

#Preview {
  ImageBrowsingView()
}
