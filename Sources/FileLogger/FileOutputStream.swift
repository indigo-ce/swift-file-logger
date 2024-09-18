import Foundation

struct FileOutputStream: TextOutputStream {
  private let fileHandle: FileHandle
  private let encoding: String.Encoding

  init(url: URL, encoding: String.Encoding = .utf8) throws {
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: url.path) {
      guard fileManager.createFile(atPath: url.path, contents: nil) else {
        throw FileError.unableToCreateFile
      }
    }

    let fileHandle = try FileHandle(forWritingTo: url)
    fileHandle.seekToEndOfFile()

    self.fileHandle = fileHandle
    self.encoding = encoding
  }

  mutating func write(_ string: String) {
    if let data = string.data(using: encoding) {
      fileHandle.write(data)
    }
  }
}

extension FileOutputStream {
  enum FileError: Error {
    case unableToCreateFile
  }
}
