import SwiftData
import SwiftUI

struct MainView: View {
  @Query(sort: \GeneratedImage.created, order: .reverse) var entries: [GeneratedImage]

  var container: ModelContainer? = try? ModelContainer(for: GeneratedImage.self)

  @State private var textFieldContent = ""

  @State private var requestInProgess = false
  @State private var haveAnyRequestsBeenMade = false

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
              ).blur(radius: requestInProgess ? 10 : 0)
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

      Text(entries.first?.revised_prompt ?? "").font(.caption).padding()

      Divider()

      List {
        ForEach(entries.dropFirst(), id: \.created) { entry in
          HStack {
            AsyncImage(url: URL(string: entry.url)) { image in
              image.interpolation(.none).resizable().scaledToFit().cornerRadius(8).frame(
                width: 80, height: 80)

            } placeholder: {
              ZStack {
                ProgressView().progressViewStyle(CircularProgressViewStyle())
                Color.gray.opacity(0.1).cornerRadius(8).frame(width: 80, height: 80)
              }
            }.padding()

            Text(entry.revised_prompt).font(.footnote).lineLimit(5)
          }

        }
      }.listStyle(.sidebar)

    }.padding().frame(width: 520, height: 900)
  }
}

#Preview {
  MainView()
}
