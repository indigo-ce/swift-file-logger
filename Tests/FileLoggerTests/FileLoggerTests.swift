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

  return paths[0]
}

func getFileSize(file: URL) throws -> UInt64 {
  let attr = try FileManager.default.attributesOfItem(atPath: file.path)
  guard let fileSize = attr[FileAttributeKey.size] as? UInt64 else {
    throw TestError.cannotGetFileSize
  }

  return fileSize
}

@Test func logToFileUsingBootstrap() async throws {
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
