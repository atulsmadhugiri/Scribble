import SwiftUI

struct TimeElapsedPill: View {
  var timeElapsed: Int
  var body: some View {
    ZStack {
      RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
        .frame(width: 80, height: 24)
        .foregroundColor(.primary)
      HStack {
        Image(systemName: "stopwatch")
        Text("\(timeElapsed)ms")
      }
      .font(.system(.callout, design: .rounded))
      .foregroundStyle(.background)
    }
  }
}

#Preview {
  TimeElapsedPill(timeElapsed: 10)
    .frame(width: 200, height: 200)
}
