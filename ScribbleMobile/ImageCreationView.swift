import SwiftData
import SwiftUI

var generatedImageFetchQuery: FetchDescriptor<GeneratedImage> {
  var descriptor = FetchDescriptor<GeneratedImage>(sortBy: [
    SortDescriptor(\.created, order: .reverse)
  ])
  descriptor.fetchLimit = 1
  return descriptor
}

struct ImageCreationView: View {
  @Environment(\.modelContext) var modelContext

  @Query(sort: \GeneratedImage.created, order: .reverse) var entries: [GeneratedImage]

  @State private var textFieldContent = ""

  @State private var requestInProgress = false
  @State private var haveAnyRequestsBeenMade = false

  @State private var selectedModel: ImageModel = .dalle3
  @State private var selectedQuality: ImageQuality = .hd

  var body: some View {

    ScrollView {
      VStack {
        ZStack {
          AsyncImage(url: URL.documentsDirectory.appending(component: entries.first?.url ?? "")) {
            phase in
            if let image = phase.image {
              ZStack {
                image.interpolation(.none).resizable().cornerRadius(8.0).scaledToFit().frame(
                  width: 300, height: 300
                ).blur(radius: requestInProgress ? 10 : 0)
                if requestInProgress == true {
                  ProgressView().progressViewStyle(CircularProgressViewStyle())
                }
              }
            } else if haveAnyRequestsBeenMade == false {
              Color.gray.opacity(0.1).cornerRadius(8.0).frame(width: 300, height: 300)
            } else {
              ZStack {
                ProgressView().progressViewStyle(CircularProgressViewStyle())
                Color.gray.opacity(0.1).cornerRadius(8.0).frame(width: 300, height: 300)
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
              let generatedImage = GeneratedImage(
                created: response.created,
                revised_prompt: response.revised_prompt,
                url: response.url,
                timeElapsed: timeElapsed
              )
              modelContext.insert(generatedImage)
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

      }.padding()
    }.scrollDismissesKeyboard(.interactively)

  }
}

#Preview {
  ImageCreationView()
}
