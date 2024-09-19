import Foundation

struct FileOutputStream: TextOutputStream {
  private let fileHandle: FileHandle
  private let encoding: String.Encoding
  let url: URL

  init(url: URL, encoding: String.Encoding = .utf8) throws {
    let fileManager = FileManager.default

    if !fileManager.fileExists(atPath: url.path) {
      guard fileManager.createFile(atPath: url.path, contents: nil) else {
        throw FileError.unableToCreateFile
      }
    }

    let fileHandle = try FileHandle(forWritingTo: url)
    try fileHandle.seekToEnd()

    self.fileHandle = fileHandle
    self.encoding = encoding
    self.url = url
  }

  mutating func write(_ string: String) {
    if let data = string.data(using: encoding) {
      fileHandle.write(data)
    }
  }

  func close() throws {
    try fileHandle.close()
  }
}

extension FileOutputStream {
  enum FileError: Error {
    case unableToCreateFile
    case cannotGetFileSize
  }
}

func getFileSize(file: URL) throws -> UInt64 {
  let attributes = try FileManager.default.attributesOfItem(atPath: file.path)
  guard let fileSize = attributes[FileAttributeKey.size] as? UInt64 else {
    throw FileOutputStream.FileError.cannotGetFileSize
  }

  return fileSize
}
