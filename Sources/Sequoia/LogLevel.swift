//===----------------------------------------------------------------------===//
//
// LogLevel.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

/// Constants that represent various levels for a `Log` instance.
///
/// In addition to the provided constants, you can create your own custom log
/// levels, using either the `init(destination:description:priority:)` initializer,
/// or one of the `custom(...)` methods.
public struct LogLevel {
  
  // MARK: - Properties
  
  /// The priority of this log level.
  public let priority: Int
  
  /// The string value of this log level.
  public let description: String
  
  /// The destination that logs of this level are sent to.
  public let destination: LogDestination
  
  // MARK: - Initializers
  
  @usableFromInline
  init(
    _ destination: LogDestination,
    _ priority: Int,
    _ description: String = #function
  ) {
    self.destination = destination
    self.description = description
    self.priority = priority
  }
  
  /// Creates a log level with a custom destination, description, and raw value.
  @inlinable
  public init(
    destination: LogDestination,
    description: String,
    priority: Int
  ) {
    self.init(destination, priority, description)
  }
}

// MARK: - Computed Constants

extension LogLevel {
  /// A log level for the console.
  @inlinable
  public static var console: Self { .init(.console, 0) }
  
  /// A log level for debug messages.
  @inlinable
  public static var debug: Self { .init(.debug, 1) }
  
  /// A log level for general information.
  @inlinable
  public static var info: Self { .init(.info, 2) }
  
  /// A log level for information that requires more attention than the `info` level,
  /// but isn't severe enough to be considered a warning.
  @inlinable
  public static var notice: Self { .init(.notice, 3) }
  
  /// A log level for warnings.
  @inlinable
  public static var warning: Self { .init(.warning, 4) }
  
  /// A log level for errors.
  @inlinable
  public static var error: Self { .init(.error, 5) }
  
  /// A log level for critical conditions.
  @inlinable
  public static var critical: Self { .init(.critical, 6) }
  
  /// A log level where the program's integrity has been compromised to the point
  /// where it must halt execution.
  @inlinable
  public static var fatal: Self { .init(.fatal, 7) }
}

// MARK: - Static Methods

extension LogLevel {
  @usableFromInline
  static func _custom(
    priority: Int,
    description: String,
    logsToFile: Bool
  ) -> Self {
    let description = description != ""
    ? description
    : "CUSTOM LEVEL: \(priority)"
    return Self(
      LogDestination(
        name: "custom-level-\(priority)",
        logsToFile: logsToFile),
      priority,
      description)
  }
  
  /// A custom log level with a priority that is higher than the given log level.
  ///
  /// - Parameters:
  ///   - level: The log level that this level's priority is higher than.
  ///   - description: A custom description of the log level, used when printing
  ///   messages to the console.
  ///   - logsToFile: A Boolean value that indicates whether the log level logs
  ///   its messages to a file.
  @inlinable
  public static func custom(
    higherThan level: Self,
    description: String = "",
    logsToFile: Bool = true
  ) -> Self {
    _custom(
      priority: level.priority + 1,
      description: description,
      logsToFile: logsToFile)
  }
  
  /// A custom log level with a priority that is lower than the given log level.
  ///
  /// - Parameters:
  ///   - level: The log level that this level's priority is lower than.
  ///   - description: A custom description of the log level, used when printing
  ///   messages to the console.
  ///   - logsToFile: A Boolean value that indicates whether the log level logs
  ///   its messages to a file.
  @inlinable
  public static func custom(
    lowerThan level: Self,
    description: String = "",
    logsToFile: Bool = true
  ) -> Self {
    _custom(
      priority: level.priority - 1,
      description: description,
      logsToFile: logsToFile)
  }
  
  /// A custom log level with a priority that is equal to the given log level.
  ///
  /// - Parameters:
  ///   - level: The log level that this level's priority is equal to.
  ///   - description: A custom description of the log level, used when printing
  ///   messages to the console.
  ///   - logsToFile: A Boolean value that indicates whether the log level logs
  ///   its messages to a file.
  @inlinable
  public static func custom(
    equalTo level: Self,
    description: String = "",
    logsToFile: Bool = true
  ) -> Self {
    _custom(
      priority: level.priority,
      description: description,
      logsToFile: logsToFile)
  }
}

// MARK: - Protocol Conformances

extension LogLevel: Codable { }

extension LogLevel: CustomStringConvertible { }

extension LogLevel: Equatable { }

extension LogLevel: Hashable { }
