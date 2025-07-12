import Foundation
import Testing

@testable import FileLogger
@testable import Logging

enum TestError: Error {
  case noDocumentDirectory
  case cannotGetFileSize
}

func getDocumentsDirectory() throws -> URL {
  let paths = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)

  guard paths.count > 0 else {
    throw TestError.noDocumentDirectory
  }

  let downloadsDir = paths[0]
  
  // Ensure the directory exists
  if !FileManager.default.fileExists(atPath: downloadsDir.path) {
    try FileManager.default.createDirectory(
      at: downloadsDir, withIntermediateDirectories: true, attributes: nil
    )
  }

  return downloadsDir
}

@Suite(.serialized) struct FileLoggerTests {
  func createLogsDirectory() throws -> URL {
    let logsDirectoryURL = try getDocumentsDirectory().appendingPathComponent(
      "Logs", isDirectory: true)

    if !FileManager.default.fileExists(atPath: logsDirectoryURL.path) {
      try FileManager.default.createDirectory(
        at: logsDirectoryURL, withIntermediateDirectories: true, attributes: nil
      )
    }

    return logsDirectoryURL
  }

  func deleteLogsDirectory() throws {
    try FileManager.default.removeItem(
      at: try getDocumentsDirectory().appendingPathComponent("Logs")
    )
  }

  @Test func logToFileUsingBootstrap() throws {
    let logFileName = "logToFileUsingBootstrap.txt"
    let logFileURL = try getDocumentsDirectory().appendingPathComponent(logFileName)

    print("File location: \(logFileURL)")

    if FileManager.default.fileExists(atPath: logFileURL.path) {
      try FileManager.default.removeItem(at: logFileURL)
    }

    try LoggingSystem.bootstrapInternal(
      FileLogger.handler(url: logFileURL)
    )

    let logger = Logger(label: "Test")
    logger.error("An error has occured. This is a test.")

    #expect(FileManager.default.fileExists(atPath: logFileURL.path))

    try FileManager.default.removeItem(at: logFileURL)
  }

  @Test func logToFileAppends() async throws {
    let logFileName = "logToFileAppends.txt"
    let logFileURL = try getDocumentsDirectory().appendingPathComponent(logFileName)

    print("File location: \(logFileURL)")

    if FileManager.default.fileExists(atPath: logFileURL.path) {
      try FileManager.default.removeItem(at: logFileURL)
    }

    try LoggingSystem.bootstrapInternal(
      FileLogger.handler(url: logFileURL)
    )

    let logger = Logger(label: "Test")
    logger.error("An error has occurred. This is a test.")
    let fileSize1 = try getFileSize(file: logFileURL)

    logger.error("An error has occurred. This is a test.")
    let fileSize2 = try getFileSize(file: logFileURL)

    #expect(fileSize2 > fileSize1)

    try FileManager.default.removeItem(at: logFileURL)
  }

  @Test func logToFileAppendsMultipleLoggers() async throws {
    let logFileName = "logToFileAppendsMultipleLoggers.txt"
    let logFileURL = try getDocumentsDirectory().appendingPathComponent(logFileName)

    print("File location: \(logFileURL)")

    if FileManager.default.fileExists(atPath: logFileURL.path) {
      try FileManager.default.removeItem(at: logFileURL)
    }

    try LoggingSystem.bootstrapInternal(
      FileLogger.handler(url: logFileURL)
    )

    let logger1 = Logger(label: "Logger 1")
    logger1.error("An error has occurred. This is a test.")
    let fileSize1 = try getFileSize(file: logFileURL)

    let logger2 = Logger(label: "Logger 2")
    logger2.error("An error has occurred. This is a test.")
    let fileSize2 = try getFileSize(file: logFileURL)

    #expect(fileSize2 > fileSize1)

    try FileManager.default.removeItem(at: logFileURL)
  }

  @Test func limitFileSize() async throws {
    let logFileName = "limitFileSize.txt"
    let logsDirectoryURL = try createLogsDirectory()
    let logFileURL = logsDirectoryURL.appendingPathComponent(logFileName)

    let originalString = "This is a test of great importance."
    let repeatedString = String(repeating: originalString, count: 100)
    let data = repeatedString.data(using: .utf8)!
    try data.write(to: logFileURL, options: .atomic)

    try LoggingSystem.bootstrapInternal(
      FileLogger.handler(url: logFileURL, maxFileSize: 1000)
    )

    let logger = Logger(label: "Test")

    for _ in 0..<10 {
      logger.error("An error has occurred. This is a test.")
    }

    let fileSize = try getFileSize(file: logFileURL)
    #expect(fileSize < 1000)

    let lines = try String(contentsOf: logFileURL).split(separator: "\n")
    #expect(lines.count == 10)

    try deleteLogsDirectory()
  }
}
