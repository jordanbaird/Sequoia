//===----------------------------------------------------------------------===//
//
// DataExtensions.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

import Foundation

extension Data {
  @usableFromInline
  @inline(__always)
  func write(
    to url: URL,
    options: WritingOptions = [],
    creatingIfNecessary shouldCreate: Bool
  ) throws {
    // Make sure the URL is a valid file URL and not something like HTTP.
    guard url.isFileURL else {
      fatalError("""
        Invalid URL scheme "\(url.scheme ?? "nil")". \
        A scheme of type "file" is required.
        """
      )
    }
    
    // Check that the file exists. If it does, skip.
    if !FileManager.default.fileExists(atPath: url.path) {
      // If the file does not exist, check that the file's parent folder exists.
      let parentExists = FileManager.default.fileExists(
        atPath: url.deletingLastPathComponent().path
      )
      
      // If it doesn't, create the parent directory.
      if !parentExists {
        try FileManager.default.createDirectory(
          at: url.deletingLastPathComponent(),
          withIntermediateDirectories: true
        )
      }
    }
    
    // Finally, write the file.
    try write(to: url, options: options)
  }
}
