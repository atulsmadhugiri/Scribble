import SwiftUI

struct ModelPill: View {
  var model: ImageModel
  var body: some View {
    ZStack {
      RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
        .frame(width: 100, height: 24)
        .foregroundColor(.teal)
      HStack {
        Image(systemName: "sparkles")
        Text(model == .dalle2 ? "DALL·E 2" : "DALL·E 3")
      }
      .font(.system(.callout, design: .rounded))
      .foregroundStyle(.background)
    }
  }
}

#Preview {
  ModelPill(model: .dalle3).frame(width: 200, height: 100)
}
