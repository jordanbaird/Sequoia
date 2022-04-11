//===----------------------------------------------------------------------===//
//
// Logger.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

import Foundation

/// A simple, yet powerful logger type.
///
/// To use this type, either create an instance by calling `init(level:prints)`,
/// or use one of the pre-existing logging methods, such as `info(_:)`, or
/// `warning(_:)`.
///
/// ```swift
/// let logger = Log(level: .notice, prints: true)
/// logger.log("A message.")
/// // Or...
/// Log.notice("A message.")
/// ```
public struct Log {
  
  // MARK: - Static Properties
  
  @usableFromInline
  static let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "[yyyy-MM-dd HH:mm:ss:0SSS]"
    return formatter
  }()
  
  @usableFromInline
  static let queue = DispatchQueue(label: "Sequoia_Log")
  
  // MARK: - Instance Properties
  
  /// The priority level of this instance.
  public let level: LogLevel
  
  /// A Boolean value that indicates whether this instance prints its log messages.
  public var prints = true
  
  /// The destination that this instance logs its messages to.
  @inlinable
  public var destination: LogDestination {
    level.destination
  }
  
  // MARK: - Initializers
  
  /// Creates an instance that logs messages to the given destination.
  /// - Parameters:
  ///   - destination: The destination to log the message to.
  ///   - prints: Whether the logger should print its messages to
  ///   the console. Default is true.
  @inlinable
  public init(
    level: LogLevel,
    prints: Bool = true
  ) {
    self.level = level
    self.prints = prints
  }
  
  // MARK: - Static Methods
  
  /// Overwrites the log file at the given level with an empty string.
  @inlinable
  public static func clear(_ level: LogLevel) {
    level.destination.contents = ""
  }
  
  /// Deletes the log file at the given level.
  @inlinable
  public static func delete(_ level: LogLevel) throws {
    try FileManager.default.removeItem(at: level.destination.file)
  }
  
  /// Returns the contents of the log file at the given level.
  @inlinable
  public static func read(_ level: LogLevel) -> String {
    level.destination.contents
  }
  
  // MARK: - Instance Methods
  
  @usableFromInline
  func _log<M: ExpressibleByLogMessageLiteral>(_ message: M) {
    if prints {
      print(destination.consoleTag.tagValue + " " + message.stringValue)
    }
    if destination.logsToFile {
      let message = Self.formatter.string(from: .init()) + " " + message.stringValue
      destination.contents.append(message + "\n")
    }
  }
  
  /// Logs a message asynchronously.
  ///
  /// The logger, depending on its settings, will print a message to the console or
  /// terminal, then append the message to the contents of the corresponding log file.
  @inlinable
  public func logAsync<M: ExpressibleByLogMessageLiteral>(_ message: M) {
    Self.queue.async {
      _log(message)
    }
  }
  
  /// Logs a message asynchronously.
  ///
  /// The logger, depending on its settings, will print a message to the console or
  /// terminal, then append the message to the contents of the corresponding log file.
  @inlinable
  public func logAsync(_ message: String) {
    logAsync(LogMessage(message))
  }
  
  /// Logs a message asynchronously.
  ///
  /// The logger, depending on its settings, will print a message to the console or
  /// terminal, then append the message to the contents of the corresponding log file.
  @inlinable
  public func logAsync(_ message: Any) {
    logAsync(LogMessage(message))
  }
  
  /// Logs a message synchronously.
  ///
  /// The logger, depending on its settings, will print a message to the console or
  /// terminal, then append the message to the contents of the corresponding log file.
  @inlinable
  public func logSync<M: ExpressibleByLogMessageLiteral>(_ message: M) {
    Self.queue.sync {
      _log(message)
    }
  }
  
  /// Logs a message synchronously.
  ///
  /// The logger, depending on its settings, will print a message to the console or
  /// terminal, then append the message to the contents of the corresponding log file.
  @inlinable
  public func logSync(_ message: String) {
    logSync(LogMessage(message))
  }
  
  /// Logs a message synchronously.
  ///
  /// The logger, depending on its settings, will print a message to the console or
  /// terminal, then append the message to the contents of the corresponding log file.
  @inlinable
  public func logSync(_ message: Any) {
    logSync(LogMessage(message))
  }
  
  /// Logs a message.
  ///
  /// The logger, depending on its settings, will print a message to the console or
  /// terminal, then append the message to the contents of the corresponding log file.
  @inlinable
  @available(*, deprecated, message: "Use 'logAsync(_:)' or 'logSync(_:)' instead.")
  public func log<M: ExpressibleByLogMessageLiteral>(_ message: M) {
    logAsync(message)
  }
  
  /// Logs a message.
  ///
  /// The logger, depending on its settings, will print a message to the
  /// console or terminal, and then append the message to the contents of
  /// the corresponding log file.
  @inlinable
  @available(*, deprecated, message: "Use 'logAsync(_:)' or 'logSync(_:)' instead.")
  public func log(_ message: String) {
    log(LogMessage(message))
  }
  
  /// Logs a message.
  ///
  /// The logger, depending on its settings, will print a message to the
  /// console or terminal, and then append the message to the contents of
  /// the corresponding log file.
  @inlinable
  @available(*, deprecated, message: "Use 'logAsync(_:)' or 'logSync(_:)' instead.")
  public func log(_ value: Any) {
    log(LogMessage(value))
  }
}

// MARK: - Main Static Log Methods

extension Log {
  /// A log for console-only messages.
  ///
  /// ```swift
  /// Log.console("A message.")
  /// ```
  ///
  /// In the example above, the message "A message." will be logged to the
  /// console. It will not be written to a file.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func console<M: ExpressibleByLogMessageLiteral>(_ message: M) {
    _console.logAsync(message)
  }
  
  /// A log for console-only messages.
  ///
  /// ```swift
  /// Log.console("A message.")
  /// ```
  ///
  /// In the example above, the message "A message." will be logged to the
  /// console. It will not be written to a file.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func console(_ message: String) {
    console(LogMessage(message))
  }
  
  /// A log for console-only messages.
  ///
  /// ```swift
  /// Log.console("A message.")
  /// ```
  ///
  /// In the example above, the message "A message." will be logged to the
  /// console. It will not be written to a file.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func console(_ message: Any) {
    console(LogMessage(message))
  }
  
  /// A log for debug messages.
  ///
  /// ```swift
  /// Log.debug("A message.")
  /// ```
  ///
  /// In the example above, the message "A message." will be logged to a file
  /// called "debug.log" in the "~/Library/Logs/\<bundle-id>" folder. If the
  /// file does not exist, it will be created.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func debug<M: ExpressibleByLogMessageLiteral>(_ message: M) {
    _debug.logAsync(message)
  }
  
  /// A log for debug messages.
  ///
  /// ```swift
  /// Log.debug("A message.")
  /// ```
  ///
  /// In the example above, the message "A message." will be logged to a file
  /// called "debug.log" in the "~/Library/Logs/\<bundle-id>" folder. If the
  /// file does not exist, it will be created.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func debug(_ message: String) {
    debug(LogMessage(message))
  }
  
  /// A log for debug messages.
  ///
  /// ```swift
  /// Log.debug("A message.")
  /// ```
  ///
  /// In the example above, the message "A message." will be logged to a file
  /// called "debug.log" in the "~/Library/Logs/\<bundle-id>" folder. If the
  /// file does not exist, it will be created.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func debug(_ message: Any) {
    debug(LogMessage(message))
  }
  
  /// A log for general information.
  ///
  /// ```swift
  /// Log.info("Something happened.")
  /// ```
  ///
  /// In the example above, the message "Something happened." will be logged to
  /// a file called "info.log" in the "~/Library/Logs/\<bundle-id>" folder. If
  /// the file does not exist, it will be created.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func info<M: ExpressibleByLogMessageLiteral>(_ message: M) {
    _info.logAsync(message)
  }
  
  /// A log for general information.
  ///
  /// ```swift
  /// Log.info("Something happened.")
  /// ```
  ///
  /// In the example above, the message "Something happened." will be logged to
  /// a file called "info.log" in the "~/Library/Logs/\<bundle-id>" folder. If
  /// the file does not exist, it will be created.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func info(_ message: String) {
    info(LogMessage(message))
  }
  
  /// A log for general information.
  ///
  /// ```swift
  /// Log.info("Something happened.")
  /// ```
  ///
  /// In the example above, the message "Something happened." will be logged to
  /// a file called "info.log" in the "~/Library/Logs/\<bundle-id>" folder. If
  /// the file does not exist, it will be created.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func info(_ message: Any) {
    info(LogMessage(message))
  }
  
  /// A log for information that requires more attention than the `info` level,
  /// but isn't severe enough to be considered a warning.
  ///
  /// ```swift
  /// Log.notice("Something concerning happened.")
  /// ```
  ///
  /// In the example above, the message "Something concerning happened." will be
  /// logged to a file called "info.log" in the "~/Library/Logs/\<bundle-id>"
  /// folder. If the file does not exist, it will be created.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func notice<M: ExpressibleByLogMessageLiteral>(_ message: M) {
    _notice.logAsync(message)
  }
  
  /// A log for information that requires more attention than the `info` level,
  /// but isn't severe enough to be considered a warning.
  ///
  /// ```swift
  /// Log.notice("Something concerning happened.")
  /// ```
  ///
  /// In the example above, the message "Something concerning happened." will be
  /// logged to a file called "info.log" in the "~/Library/Logs/\<bundle-id>"
  /// folder. If the file does not exist, it will be created.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func notice(_ message: String) {
    notice(LogMessage(message))
  }
  
  /// A log for information that requires more attention than the `info` level,
  /// but isn't severe enough to be considered a warning.
  ///
  /// ```swift
  /// Log.notice("Something concerning happened.")
  /// ```
  ///
  /// In the example above, the message "Something concerning happened." will be
  /// logged to a file called "info.log" in the "~/Library/Logs/\<bundle-id>"
  /// folder. If the file does not exist, it will be created.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func notice(_ message: Any) {
    notice(LogMessage(message))
  }
  
  /// A log for warnings.
  ///
  /// ```swift
  /// Log.warning("Strange things are afoot at the Circle-K.")
  /// ```
  ///
  /// In the example above, the message "Strange things are afoot at the
  /// Circle-K." will be logged to a file called "warning.log" in the
  /// "~/Library/Logs/\<bundle-id>" folder. If the file does not exist, it
  /// will be created.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func warning<M: ExpressibleByLogMessageLiteral>(_ message: M) {
    _warning.logAsync(message)
  }
  
  /// A log for warnings.
  ///
  /// ```swift
  /// Log.warning("Strange things are afoot at the Circle-K.")
  /// ```
  ///
  /// In the example above, the message "Strange things are afoot at the
  /// Circle-K." will be logged to a file called "warning.log" in the
  /// "~/Library/Logs/\<bundle-id>" folder. If the file does not exist, it
  /// will be created.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func warning(_ message: String) {
    warning(LogMessage(message))
  }
  
  /// A log for warnings.
  ///
  /// ```swift
  /// Log.warning("Strange things are afoot at the Circle-K.")
  /// ```
  ///
  /// In the example above, the message "Strange things are afoot at the
  /// Circle-K." will be logged to a file called "warning.log" in the
  /// "~/Library/Logs/\<bundle-id>" folder. If the file does not exist, it
  /// will be created.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func warning(_ message: Any) {
    warning(LogMessage(message))
  }
  
  /// A log for errors.
  ///
  /// ```swift
  /// Log.error("An error has occurred.")
  /// ```
  ///
  /// In the example above, the message "An error has occurred." will be logged
  /// to a file called "error.log" in the "~/Library/Logs/\<bundle-id>" folder.
  /// If the file does not exist, it will be created.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func error<M: ExpressibleByLogMessageLiteral>(_ message: M) {
    _error.logAsync(message)
  }
  
  /// A log for errors.
  ///
  /// ```swift
  /// Log.error("An error has occurred.")
  /// ```
  ///
  /// In the example above, the message "An error has occurred." will be logged
  /// to a file called "error.log" in the "~/Library/Logs/\<bundle-id>" folder.
  /// If the file does not exist, it will be created.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func error(_ message: String) {
    error(LogMessage(message))
  }
  
  /// A log for errors.
  ///
  /// ```swift
  /// Log.error("An error has occurred.")
  /// ```
  ///
  /// In the example above, the message "An error has occurred." will be logged
  /// to a file called "error.log" in the "~/Library/Logs/\<bundle-id>" folder.
  /// If the file does not exist, it will be created.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func error(_ message: Any) {
    error(LogMessage(message))
  }
  
  /// A log for critical conditions.
  ///
  /// ```swift
  /// Log.critical("A problem exists that must be fixed immediately.")
  /// ```
  ///
  /// In the example above, the message "A problem exists that must be fixed
  /// immediately." will be logged to a file called "critical.log" in the
  /// "~/Library/Logs/\<bundle-id>" folder. If the file does not exist, it will
  /// be created.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func critical<M: ExpressibleByLogMessageLiteral>(_ message: M) {
    _critical.logAsync(message)
  }
  
  /// A log for critical conditions.
  ///
  /// ```swift
  /// Log.critical("A problem exists that must be fixed immediately.")
  /// ```
  ///
  /// In the example above, the message "A problem exists that must be fixed
  /// immediately." will be logged to a file called "critical.log" in the
  /// "~/Library/Logs/\<bundle-id>" folder. If the file does not exist, it will
  /// be created.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func critical(_ message: String) {
    critical(LogMessage(message))
  }
  
  /// A log for critical conditions.
  ///
  /// ```swift
  /// Log.critical("A problem exists that must be fixed immediately.")
  /// ```
  ///
  /// In the example above, the message "A problem exists that must be fixed
  /// immediately." will be logged to a file called "critical.log" in the
  /// "~/Library/Logs/\<bundle-id>" folder. If the file does not exist, it will
  /// be created.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func critical(_ message: Any) {
    critical(LogMessage(message))
  }
  
  /// A log level where the program's integrity has been compromised to the point
  /// where it must halt execution.
  ///
  /// ```swift
  /// Log.fatal("Something has gone very wrong.")
  /// ```
  ///
  /// In the example above, the message "Something has gone very wrong." will be
  /// logged to a file called "fatal.log" in the "~/Library/Logs/\<bundle-id>"
  /// folder, and execution of the program will be halted. If the file does not
  /// exist, it will be created.
  ///
  /// - Parameters:
  ///   - message: The message to log.
  ///   - stopExecution: Whether the program should stop execution. If set to true,
  ///   this will trigger a fatal error behind the scenes.
  @inlinable
  public static func fatal<M: ExpressibleByLogMessageLiteral>(
    _ message: M,
    stopExecution: Bool = true
  ) {
    _fatal.logSync(message)
    if stopExecution {
      fatalError(message.stringValue)
    }
  }
  
  /// A log level where the program's integrity has been compromised to the point
  /// where it must halt execution.
  ///
  /// ```swift
  /// Log.fatal("Something has gone very wrong.")
  /// ```
  ///
  /// In the example above, the message "Something has gone very wrong." will be
  /// logged to a file called "fatal.log" in the "~/Library/Logs/\<bundle-id>"
  /// folder, and execution of the program will be halted. If the file does not
  /// exist, it will be created.
  ///
  /// - Parameters:
  ///   - message: The message to log.
  ///   - stopExecution: Whether the program should stop execution. If set to true,
  ///   this will trigger a fatal error behind the scenes.
  @inlinable
  public static func fatal(_ message: String, stopExecution: Bool = true) {
    fatal(LogMessage(message), stopExecution: stopExecution)
  }
  
  /// A log level where the program's integrity has been compromised to the point
  /// where it must halt execution.
  ///
  /// ```swift
  /// Log.fatal("Something has gone very wrong.")
  /// ```
  ///
  /// In the example above, the message "Something has gone very wrong." will be
  /// logged to a file called "fatal.log" in the "~/Library/Logs/\<bundle-id>"
  /// folder, and execution of the program will be halted. If the file does not
  /// exist, it will be created.
  ///
  /// - Parameters:
  ///   - message: The message to log.
  ///   - stopExecution: Whether the program should stop execution. If set to true,
  ///   this will trigger a fatal error behind the scenes.
  @inlinable
  public static func fatal(_ message: Any, stopExecution: Bool = true) {
    fatal(LogMessage(message), stopExecution: stopExecution)
  }
  
  /// A log level where the program's integrity has been compromised to the point
  /// where it must halt execution.
  ///
  /// ```swift
  /// Log.fatal("Something has gone very wrong.")
  /// ```
  ///
  /// In the example above, the message "Something has gone very wrong." will be
  /// logged to a file called "fatal.log" in the "~/Library/Logs/\<bundle-id>"
  /// folder, and execution of the program will be halted. If the file does not
  /// exist, it will be created.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func fatal<M: ExpressibleByLogMessageLiteral>(_ message: M) -> Never {
    _fatal.logSync(message)
    fatalError(message.stringValue)
  }
  
  /// A log level where the program's integrity has been compromised to the point
  /// where it must halt execution.
  ///
  /// ```swift
  /// Log.fatal("Something has gone very wrong.")
  /// ```
  ///
  /// In the example above, the message "Something has gone very wrong." will be
  /// logged to a file called "fatal.log" in the "~/Library/Logs/\<bundle-id>"
  /// folder, and execution of the program will be halted. If the file does not
  /// exist, it will be created.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func fatal(_ message: String) -> Never {
    fatal(LogMessage(message))
  }
  
  /// A log level where the program's integrity has been compromised to the point
  /// where it must halt execution.
  ///
  /// ```swift
  /// Log.fatal("Something has gone very wrong.")
  /// ```
  ///
  /// In the example above, the message "Something has gone very wrong." will be
  /// logged to a file called "fatal.log" in the "~/Library/Logs/\<bundle-id>"
  /// folder, and execution of the program will be halted. If the file does not
  /// exist, it will be created.
  ///
  /// - Parameter message: The message to log.
  @inlinable
  public static func fatal(_ message: Any) -> Never {
    fatal(LogMessage(message))
  }
  
  /// A log for file-only messages.
  ///
  /// ```swift
  /// Log.silent(level: .info, "A message.")
  /// ```
  ///
  /// In the example above, the message "A message." will be logged to a file
  /// called "info.log" in the "~/Library/Logs/\<bundle-id>" folder. If the
  /// file does not exist, it will be created.
  ///
  /// No message will be logged to the console.
  ///
  /// - Parameters:
  ///   - level: The level to log the message at.
  ///   - message: The message to log.
  @inlinable
  public static func silent<M: ExpressibleByLogMessageLiteral>(level: LogLevel, _ message: M) {
    _silent(level: level).logAsync(message)
  }
  
  /// A log for file-only messages.
  ///
  /// ```swift
  /// Log.silent(level: .info, "A message.")
  /// ```
  ///
  /// In the example above, the message "A message." will be logged to a file
  /// called "info.log" in the "~/Library/Logs/\<bundle-id>" folder. If the
  /// file does not exist, it will be created.
  ///
  /// No message will be logged to the console.
  ///
  /// - Parameters:
  ///   - level: The level to log the message at.
  ///   - message: The message to log.
  @inlinable
  public static func silent(level: LogLevel, _ message: String) {
    silent(level: level, LogMessage(message))
  }
  
  /// A log for file-only messages.
  ///
  /// ```swift
  /// Log.silent(level: .info, "A message.")
  /// ```
  ///
  /// In the example above, the message "A message." will be logged to a file
  /// called "info.log" in the "~/Library/Logs/\<bundle-id>" folder. If the
  /// file does not exist, it will be created.
  ///
  /// No message will be logged to the console.
  ///
  /// - Parameters:
  ///   - level: The level to log the message at.
  ///   - message: The message to log.
  @inlinable
  public static func silent(level: LogLevel, _ message: Any) {
    silent(level: level, LogMessage(message))
  }
}

// MARK: - Internal Helpers

extension Log {
  @usableFromInline
  static let _console = Self(level: .console)
  
  @usableFromInline
  static let _debug = Self(level: .debug)
  
  @usableFromInline
  static let _info = Self(level: .info)
  
  @usableFromInline
  static let _notice = Self(level: .notice)
  
  @usableFromInline
  static let _warning = Self(level: .warning)
  
  @usableFromInline
  static let _error = Self(level: .error)
  
  @usableFromInline
  static let _critical = Self(level: .critical)
  
  @usableFromInline
  static let _fatal = Self(level: .fatal)
  
  @usableFromInline
  static func _silent(level: LogLevel) -> Self {
    .init(level: level, prints: false)
  }
}

// MARK: - Protocol Conformances

extension Log: CustomStringConvertible {
  @inlinable
  public var description: String {
    "\(Self.self)(\(destination.name))"
  }
}
