//===----------------------------------------------------------------------===//
//
// LogMessage.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

/// A type that represents a message used by a log.
///
/// This type can be expressed by most literals, such as a string literal, integer
/// literal, or float literal. An instance can also be created using the `init(_:)`
/// initializer.
///
/// ```swift
/// let stringMessage: LogMessage = "A message."
/// let intMessage: LogMessage = 6378
/// let floatMessage: LogMessage = 198.7364
/// let message = LogMessage("A message.")
/// ```
public struct LogMessage: ExpressibleByLogMessageLiteral {
  public let message: Any
  
  @inlinable
  public init(_ message: Any) {
    self.message = message
  }
}

/// A type that can be initialized using a number of literal representations,
/// and that can be displayed/written as a message using a `Log` instance.
public protocol ExpressibleByLogMessageLiteral:
  ExpressibleByStringInterpolation,
  ExpressibleByIntegerLiteral,
  ExpressibleByFloatLiteral,
  ExpressibleByBooleanLiteral,
  ExpressibleByArrayLiteral,
  ExpressibleByDictionaryLiteral
{
  /// The underlying value of this log message.
  var message: Any { get }
  
  /// Creates a log message with the given underlying value.
  init(_ message: Any)
}

extension ExpressibleByLogMessageLiteral {
  /// The string value of this log message.
  @inlinable
  public var stringValue: String {
    .init(describing: message)
  }
}

extension ExpressibleByLogMessageLiteral {
  @inlinable
  public init(stringLiteral value: String) {
    self.init(value)
  }
  
  @inlinable
  public init(stringInterpolation: DefaultStringInterpolation) {
    self.init(String(stringInterpolation: stringInterpolation))
  }
  
  @inlinable
  public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
    self.init(value)
  }
  
  @inlinable
  public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
    self.init(value)
  }
  
  @inlinable
  public init(integerLiteral value: Int) {
    self.init(value)
  }
  
  @inlinable
  public init(floatLiteral value: Double) {
    self.init(value)
  }
  
  @inlinable
  public init(booleanLiteral value: Bool) {
    self.init(value)
  }
  
  @inlinable
  public init(arrayLiteral elements: Any...) {
    self.init(elements)
  }
  
  @inlinable
  public init(dictionaryLiteral elements: (AnyHashable, Any)...) {
    let dict = elements.reduce(into: [:]) {
      $0[String(describing: $1.0.base)] = $1.1
    }
    self.init(dict)
  }
}
