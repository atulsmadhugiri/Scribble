import SwiftData
import SwiftUI

struct MainView: View {
  @Query var entries: [GeneratedImage]

  var container: ModelContainer? = try? ModelContainer(for: GeneratedImage.self)

  @State private var textFieldContent = ""
  @State private var lastGeneratedImageURL = ""

  @State private var requestInProgess = false
  @State private var haveAnyRequestsBeenMade = false

  @State private var rewrittenPrompt = ""

  var body: some View {

    VStack {

      TextField("Prompt", text: $textFieldContent).frame(
        width: 400
      ).textFieldStyle(.roundedBorder).onSubmit {
        requestInProgess = true
        haveAnyRequestsBeenMade = true
        Task {
          do {
            print(entries)
            let response = try await performImageGenerationRequest(prompt: textFieldContent)
            lastGeneratedImageURL = response.url
            rewrittenPrompt = response.revised_prompt
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
        AsyncImage(url: URL(string: lastGeneratedImageURL)) { phase in
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

      Text(rewrittenPrompt).font(.caption).padding()

      List {
        ForEach(entries, id: \.created) { entry in
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

            Text("")
            Text(entry.revised_prompt).font(.footnote).lineLimit(nil)
          }

        }
      }.listStyle(.sidebar)

    }.padding().frame(width: 520, height: 720)
  }
}

#Preview {
  MainView()
}
