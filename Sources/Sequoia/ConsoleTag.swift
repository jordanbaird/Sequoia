//===----------------------------------------------------------------------===//
//
// ConsoleTag.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

/// A tag that will be displayed before a log message in the console.
///
/// Whatever value is provided will automatically be converted into the correct
/// tag format. For example, a console tag with the raw value of "warning" will
/// be displayed in the console as "`[WARNING]`".
public struct ConsoleTag {
  
  // MARK: - Instance Properties
  
  public let rawValue: String
  
  @usableFromInline
  let tagValue: String
  
  // MARK: - Initializers
  
  public init(rawValue: String) {
    self.rawValue = rawValue
    var tagValue = rawValue.uppercased()
    if !tagValue.hasPrefix("[") {
      tagValue = "[" + tagValue
    }
    if !tagValue.hasSuffix("]") {
      tagValue += "]"
    }
    self.tagValue = tagValue
  }
  
  public init(_ rawValue: String) {
    self.init(rawValue: rawValue)
  }
  
  public init(stringLiteral value: String) {
    self.init(value)
  }
  
  public init(stringInterpolation: DefaultStringInterpolation) {
    self.init(.init(stringInterpolation: stringInterpolation))
  }
  
  public init(unicodeScalarLiteral value: String) {
    self.init(value)
  }
  
  public init(extendedGraphemeClusterLiteral value: String) {
    self.init(value)
  }
}

// MARK: - Protocol Conformances

extension ConsoleTag: Codable { }

extension ConsoleTag: Equatable { }

extension ConsoleTag: ExpressibleByStringInterpolation { }

extension ConsoleTag: Hashable { }

extension ConsoleTag: RawRepresentable { }
