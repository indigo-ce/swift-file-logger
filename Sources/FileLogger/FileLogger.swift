import Foundation
import Logging

public struct FileLogger: LogHandler {
  private var label: String
  private let stream: FileOutputStream
  private let maxFileSize: UInt64

  public var logLevel: Logger.Level = .info

  public var metadata = Logger.Metadata()

  public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
    get {
      return self.metadata[metadataKey]
    }
    set {
      self.metadata[metadataKey] = newValue
    }
  }

  public init(
    label: String,
    fileURL: URL,
    maxFileSize: UInt64 = 1024 * 1024 * 10
  ) throws {
    self.label = label
    self.stream = try FileOutputStream(url: fileURL)
    self.maxFileSize = maxFileSize
  }

  init(
    label: String,
    fileURL: URL,
    maxFileSize: UInt64 = 1024 * 1024 * 10,
    stream: FileOutputStream
  ) {
    self.label = label
    self.maxFileSize = maxFileSize
    self.stream = stream
  }

  public static func handler(
    url: URL,
    maxFileSize: UInt64 = 1024 * 1024 * 10
  ) throws -> @Sendable (String) -> any LogHandler {
    if let size = try? getFileSize(file: url) {
      do {
        if size > maxFileSize {
          // Append "-archived" to the file name.
          let archivedFileURL = url.deletingPathExtension()
            .appendingPathExtension("archived.\(UUID().uuidString.prefix(8))")
            .appendingPathExtension(url.pathExtension)

          // Move the current file to the archived file.
          try FileManager.default.moveItem(at: url, to: archivedFileURL)
        }
      } catch {
        print("Failed to rotate file: \(error)")
      }
    }

    let stream = try FileOutputStream(url: url)

    return { label in
      Self(
        label: label,
        fileURL: url,
        maxFileSize: maxFileSize,
        stream: stream
      )
    }
  }

  public func log(
    level: Logger.Level,
    message: Logger.Message,
    metadata: Logger.Metadata?,
    source: String,
    file: String,
    function: String,
    line: UInt
  ) {
    var stream = self.stream

    stream.write(
      "\(timestamp()) \(level) \(label): \(message)\n"
    )
  }

  private func timestamp() -> String {
    var buffer = [Int8](repeating: 0, count: 255)
    var timestamp = time(nil)
    let localTime = localtime(&timestamp)
    strftime(&buffer, buffer.count, "%Y-%m-%dT%H:%M:%S%z", localTime)
    return buffer.withUnsafeBufferPointer {
      $0.withMemoryRebound(to: CChar.self) {
        String(cString: $0.baseAddress!)
      }
    }
  }
}
