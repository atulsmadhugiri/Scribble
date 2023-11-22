import Foundation

enum ScribbleError: Error {
  case couldNotCreateItemProvider
}

func getItemProvider(for file: URL) throws -> NSItemProvider {
  let fileName = file.lastPathComponent
  let temporaryPath = URL(fileURLWithPath: NSTemporaryDirectory())
    .appending(component: "onDrag")
    .appending(component: fileName)

  try FileManager.default.createDirectory(
    at: temporaryPath.deletingLastPathComponent(),
    withIntermediateDirectories: true)

  if !FileManager.default.fileExists(atPath: temporaryPath.path) {
    try FileManager.default.copyItem(at: file, to: temporaryPath)
  }

  guard let provider = NSItemProvider(contentsOf: temporaryPath) else {
    throw ScribbleError.couldNotCreateItemProvider
  }
  provider.suggestedName = fileName
  return provider
}
