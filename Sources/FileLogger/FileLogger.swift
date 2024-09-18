import Foundation
import Logging

public struct FileLogger: LogHandler {
  private let stream: FileOutputStream
  private var label: String

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

  public init(label: String, localFile url: URL) throws {
    self.label = label
    self.stream = try FileOutputStream(url: url)
  }

  init(label: String, stream: FileOutputStream) {
    self.label = label
    self.stream = stream
  }

  static func handler(url: URL) throws -> @Sendable (String) -> any LogHandler {
    let stream = try FileOutputStream(url: url)

    return { label in
      Self(label: label, stream: stream)
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
