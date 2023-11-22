import SwiftData
import SwiftUI

struct MainView: View {
  @Query(sort: \GeneratedImage.created, order: .reverse) var entries: [GeneratedImage]

  var container: ModelContainer? = try? ModelContainer(for: GeneratedImage.self)

  @State private var textFieldContent = ""

  @State private var requestInProgess = false
  @State private var haveAnyRequestsBeenMade = false

  @State private var searchTerm = ""
  var filteredEntries: [GeneratedImage] {
    guard !searchTerm.isEmpty else { return entries }
    return entries.filter { $0.revised_prompt.localizedCaseInsensitiveContains(searchTerm) }
  }

  var body: some View {

    VStack {

      TextField("Prompt", text: $textFieldContent).frame(
        width: 400
      ).textFieldStyle(.roundedBorder).onSubmit {
        requestInProgess = true
        haveAnyRequestsBeenMade = true
        Task {
          do {
            let response = try await performImageGenerationRequest(prompt: textFieldContent)
            if let container = container {
              let generatedImage = GeneratedImage(
                created: response.created,
                revised_prompt: response.revised_prompt,
                url: response.url)
              container.mainContext.insert(generatedImage)
            }
            NSSound(named: "Funk")?.play()
            requestInProgess = false
          } catch {
            requestInProgess = false
          }
        }
      }

      ZStack {
        AsyncImage(url: URL(string: entries.first?.url ?? "")) { phase in
          if let image = phase.image {
            ZStack {
              image.interpolation(.none).resizable().scaledToFit().cornerRadius(8).frame(
                width: 400, height: 400
              ).blur(radius: requestInProgess ? 10 : 0).onDrag {
                if let firstEntry = entries.first {
                  let existingURL = URL(string: firstEntry.url)
                  do {
                    return try getItemProvider(for: existingURL!)
                  } catch {
                    print("Unable to get NSItemProvider for existingURL")
                  }
                }
                return NSItemProvider()
              }
              if requestInProgess == true {
                ProgressView().progressViewStyle(CircularProgressViewStyle())
              }
            }
          } else if haveAnyRequestsBeenMade == false {
            Color.gray.opacity(0.1).cornerRadius(8).frame(width: 400, height: 400)
          } else {
            ZStack {
              ProgressView().progressViewStyle(CircularProgressViewStyle())
              Color.gray.opacity(0.1).cornerRadius(8).frame(width: 400, height: 400)
            }
          }
        }
      }

      Divider()

      List {
        Divider()
        ForEach(filteredEntries, id: \.created) { entry in
          HStack {
            AsyncImage(url: URL(string: entry.url)) { image in
              image.interpolation(.none).resizable().scaledToFit().cornerRadius(8).frame(
                width: 100, height: 100
              ).transition(.opacity.animation(.default)).onDrag {

                let existingURL = URL(string: entry.url)
                do {
                  return try getItemProvider(for: existingURL!)
                } catch {
                  print("Unable to get NSItemProvider for existingURL")
                }
                return NSItemProvider()
              }

            } placeholder: {
              ZStack {
                ProgressView().progressViewStyle(CircularProgressViewStyle())
                Color.gray.opacity(0.1).cornerRadius(8).frame(width: 100, height: 100)
              }
            }
            Spacer()
            Text(entry.revised_prompt).font(.footnote).lineLimit(6)
          }
          Divider()
        }
      }.listStyle(.sidebar)
        .searchable(text: $searchTerm, placement: .sidebar, prompt: "Search generations")

    }.padding().frame(width: 460, height: 1000)
  }
}

#Preview {
  MainView()
}
