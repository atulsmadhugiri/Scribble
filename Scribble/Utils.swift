import Foundation

func getItemProvider(for file: URL) -> NSItemProvider {
  let fileName = file.lastPathComponent

  let temporaryPathString = "\(NSTemporaryDirectory())onDrag/\(fileName)"
  let temporaryPath: URL = URL(fileURLWithPath: temporaryPathString)

  if FileManager.default.fileExists(atPath: temporaryPathString) {
    if let provider = NSItemProvider(contentsOf: temporaryPath) {
      provider.suggestedName = fileName
      return provider
    }
  }

  do {
    try FileManager.default.createDirectory(
      at: temporaryPath.deletingLastPathComponent(),
      withIntermediateDirectories: true)

    try FileManager.default.copyItem(at: file, to: temporaryPath)
    if let provider = NSItemProvider(contentsOf: temporaryPath) {
      provider.suggestedName = fileName
      return provider
    }
  } catch {
    print("Error creating temporary file in .onDrag: \(error)")
  }
  return NSItemProvider()
}
