#!/bin/bash

# Swift 6.1.2 Docker Testing Script
# Based on: https://www.swift.org/documentation/server/guides/testing.html

set -e

echo "🐳 Running Swift tests in Docker container..."

docker run --rm \
  --volume "$(pwd):/workspace" \
  --workdir /workspace \
  swift:6.1.2-jammy \
  swift test

echo "✅ Tests completed successfully!"
