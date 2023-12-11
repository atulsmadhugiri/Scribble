import SwiftData
import SwiftUI

struct MainView: View {
  @Query(sort: \GeneratedImage.created, order: .reverse) var entries: [GeneratedImage]

  var container: ModelContainer? = try? ModelContainer(for: GeneratedImage.self)

  @State private var textFieldContent = ""

  @State private var requestInProgress = false
  @State private var haveAnyRequestsBeenMade = false

  @State private var selectedModel: ImageModel = .dalle3
  @State private var selectedQuality: ImageQuality = .hd

  @State private var searchTerm = ""
  var filteredEntries: [GeneratedImage] {
    guard !searchTerm.isEmpty else { return entries }
    return entries.filter { $0.revised_prompt.localizedCaseInsensitiveContains(searchTerm) }
  }

  var body: some View {

    VStack {
      ZStack {
        AsyncImage(url: URL(string: entries.first?.url ?? "")) { phase in
          if let image = phase.image {
            ZStack {
              image.interpolation(.none).resizable().cornerRadius(8.0).scaledToFit().frame(
                width: 400, height: 400
              ).blur(radius: requestInProgress ? 10 : 0).onDrag {
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
              if requestInProgress == true {
                ProgressView().progressViewStyle(CircularProgressViewStyle())
              }
            }
          } else if haveAnyRequestsBeenMade == false {
            Color.gray.opacity(0.1).cornerRadius(8.0).frame(width: 400, height: 400)
          } else {
            ZStack {
              ProgressView().progressViewStyle(CircularProgressViewStyle())
              Color.gray.opacity(0.1).cornerRadius(8.0).frame(width: 400, height: 400)
            }
          }
        }
      }

      TextField("Prompt", text: $textFieldContent).frame(
        width: 360
      ).textFieldStyle(.roundedBorder).onSubmit {
        requestInProgress = true
        haveAnyRequestsBeenMade = true
        Task {
          do {
            let startTime = Date()
            let response = try await performImageGenerationRequest(
              prompt: textFieldContent, model: selectedModel, quality: selectedQuality)
            let endTime = Date()
            let timeElapsed = endTime.timeIntervalSince(startTime)
            if let container = container {
              let generatedImage = GeneratedImage(
                created: response.created,
                revised_prompt: response.revised_prompt,
                url: response.url,
                timeElapsed: timeElapsed
              )
              container.mainContext.insert(generatedImage)
            }
            #if os(macOS)
              NSSound(named: "Funk")?.play()
            #endif
            requestInProgress = false
          } catch {
            requestInProgress = false
          }
        }
      }

      HStack {
        if let first = entries.first {
          TimeElapsedPill(timeElapsed: first.timeElapsed ?? 0.0)
        }
        ModelPill(model: .dalle3)
      }

      Divider()

      Picker("", selection: $selectedModel) {
        Text("DALL·E 2").tag(ImageModel.dalle2)
        Text("DALL·E 3").tag(ImageModel.dalle3)
      }.pickerStyle(.segmented).labelsHidden()

      Picker("", selection: $selectedQuality) {
        Text("Standard").tag(ImageQuality.standard)
        Text("HD").tag(ImageQuality.hd)
      }.pickerStyle(.segmented).labelsHidden()

      Divider()

      NavigationView {
        List {
          ForEach(filteredEntries, id: \.id) { entry in
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
              Text(entry.revised_prompt).font(.footnote).lineLimit(6)
            }
          }
        }.searchable(text: $searchTerm, placement: .automatic, prompt: "")
          .listStyle(.plain)
          .navigationBarTitle("Image Generations", displayMode: .inline)
      }

    }.padding()
  }
}

#Preview {
  MainView()
}
