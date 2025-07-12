# 🪻 swift-file-logger

A Swift logging library that writes log messages to files with automatic file rotation based on size limits. It is part of the [Indigo Stack](https://indigostack.org).

## Features

- File-based logging with automatic file rotation
- Configurable maximum file size limits
- Compatible with Swift's standard `Logging` framework
- Cross-platform support (macOS, iOS, watchOS, tvOS)
- Swift 6.0+ support with strict concurrency

## Installation

Add this package to your Swift project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/indigo-ce/swift-file-logger.git", from: "1.0.0")
]
```

## Usage

```swift
import FileLogger
import Logging

// Bootstrap the logging system with FileLogger
let logFileURL = URL(fileURLWithPath: "/path/to/your/log/file.txt")
try LoggingSystem.bootstrapInternal(
    FileLogger.handler(url: logFileURL, maxFileSize: 1024 * 1024) // 1MB limit
)

// Use standard Swift Logging
let logger = Logger(label: "MyApp")
logger.info("Application started")
logger.error("An error occurred")
```

## File Rotation

When a log file exceeds the specified maximum size, FileLogger automatically:

1. Renames the current file with an archived suffix and UUID
2. Creates a new log file at the original location

Example: `app.log` becomes `app.archived.a1b2c3d4.log`

## Configuration

- `maxFileSize`: Maximum file size in bytes before rotation (default: 10MB)
- File format: `timestamp level label: message`

## Requirements

- Swift 6.0+
- Platforms: macOS 12+, iOS 16+, watchOS 8+, tvOS 16+

## Development

### Running Tests

```bash
swift test
```

### Docker Testing

Use the included Docker script for testing in a Linux environment:

```bash
./test-docker.sh
```

## License

MIT License
