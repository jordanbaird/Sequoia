//===----------------------------------------------------------------------===//
//
// LogDestination.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

import Foundation

/// A destination that a `Log` instance sends its messages to.
///
/// Create a log destination using one of this type's initializers, such as
/// `init(file:)` or `init(name:)`.
///
/// ```swift
/// let destination = LogDestination(file: someURL)
/// let destination = LogDestination(name: "some-name")
/// ```
///
/// If created using the `init(file:)` initializer, the instance's file extension
/// will remain exactly as you provided it. If created using `init(name:)`, the
/// '.log' extension will be appended to the end.
public final class LogDestination {
  
  // MARK: - Static Properties
  
  @usableFromInline
  static let logFolderLocation: URL = {
    let library = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
    let logsURL = library.appendingPathComponent("Logs")
    
    let dispName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
    let bundleID = Bundle.main.bundleIdentifier
    
    if let dispName = dispName {
      return logsURL.appendingPathComponent(dispName)
    } else if let bundleID = bundleID {
      return logsURL.appendingPathComponent(bundleID)
    } else {
      fatalError(
        "No valid bundle identifier or display name is available to " +
        "use as a log folder. Manually choose a destination instead."
      )
    }
  }()
  
  // MARK: - Instance Properties
  
  /// The tag that will be displayed before log messages to this destination
  /// in the console.
  public let consoleTag: ConsoleTag
  
  /// A Boolean value that indicates whether or not messages sent to this
  /// destination are written to a file.
  public let logsToFile: Bool
  
  /// The name of this destination.
  public let name: String
  
  /// The contents of the log file associated with this destination.
  ///
  /// If `logsToFile` is `false`, this property returns an empty string.
  @inlinable
  public var contents: String {
    get {
      guard logsToFile else {
        return ""
      }
      
      guard fileExists else {
        // Setting the value of 'contents' creates a new file.
        self.contents = ""
        return ""
      }
      
      guard
        let data = try? Data(contentsOf: file),
        let string = String(data: data, encoding: .utf8)
      else {
        handleCorruptedFile()
        return ""
      }
      
      return string
    }
    set {
      guard logsToFile else {
        return
      }
      do {
        try newValue.data(using: .utf8)?.write(to: file, creatingIfNecessary: true)
      } catch {
        printWriteErrorMessage()
      }
    }
  }
  
  /// The log file associated with this destination.
  public var file: URL { _file }
  
  // Private helper
  private var _file: URL
  
  /// A Boolean value that indicates whether a file exists at this destination.
  @inlinable
  public var fileExists: Bool {
    access(file.path, F_OK) == 0
  }
  
  // MARK: - Initializers
  
  // Internal implementation
  @usableFromInline
  init(
    _ file: URL,
    _ name: String,
    _ consoleTag: ConsoleTag,
    _ logsToFile: Bool
  ) {
    _file = file
    self.name = name
    self.consoleTag = consoleTag
    self.logsToFile = logsToFile
  }
  
  /// Creates a destination with the given file, name, and console tag.
  ///
  /// `logsToFile` will automatically be set to `true`.
  ///
  /// - Parameters:
  ///   - file: The file that messages sent to this destination will be written.
  ///   - name: The name of the destination.
  ///   - consoleTag: The tag that will be displayed in the console.
  @inlinable
  public convenience init(
    file: URL,
    name: String,
    consoleTag: ConsoleTag
  ) {
    self.init(file, name, consoleTag, true)
  }
  
  /// Creates a destination with the given file and name.
  ///
  /// A console tag will automatically be created based on the provided name.
  /// `logsToFile` will automatically be set to `true`.
  ///
  /// - Parameters:
  ///   - file: The file that messages sent to this destination will be written.
  ///   - name: The name of the destination.
  @inlinable
  public convenience init(file: URL, name: String) {
    self.init(file, name, .init(name), true)
  }
  
  /// Creates a destination with the given name, using the default log folder location.
  ///
  /// A console tag will automatically be created based on the provided name. The name
  /// will have the '.log' file extension appended to it, before being saved as a file
  /// (if `logsToFile` is set to `true`).
  ///
  /// - Parameters:
  ///   - name: The name of the destination.
  ///   - logsToFile: A Boolean value that indicates whether or not messages sent to this
  ///   destination are written to a file.
  @inlinable
  public convenience init(name: String, logsToFile: Bool) {
    let fileName = name.hasSuffix(".log") ? name : name + ".log"
    let file = Self.logFolderLocation.appendingPathComponent(fileName)
    self.init(file, name, .init(name), logsToFile)
  }
  
  /// Creates a destination assigned to the given file URL.
  ///
  /// A name and console tag will automatically be created based on the last path
  /// component of the provided URL. `logsToFile` will automatically be set to `true`.
  ///
  /// - Parameter file: The file that messages sent to this destination will be written.
  @inlinable
  public convenience init(file: URL) {
    let name = file.deletingPathExtension().lastPathComponent
    self.init(file, name, .init(name), true)
  }
  
  // MARK: - Methods
  
  @usableFromInline
  func handleCorruptedFile() {
    var newFile = _file
    let ext = newFile.pathExtension
    newFile.deletePathExtension()
    var number = file.lastPathComponent
      .reversed()
      .prefix(while: \.isNumber)
      .reversed()
      .reduce(into: "") { $0.append($1) }
    number = String((Int(number) ?? 0) + 1)
    newFile = newFile
      .deletingLastPathComponent()
      .appendingPathComponent(newFile.lastPathComponent + " " + number)
      .appendingPathExtension(ext)
    let message = """
      [
        \(Log.self): Could not read log file at path "\(file.path)"
        \(Log.self): The log file may be corrupted.
        \(Log.self): A new file will be created at "\(newFile.path)"
      ]
      """
    print(message)
    _file = newFile
  }
  
  @usableFromInline
  func printWriteErrorMessage() {
    print("[\(Log.self)] Could not write to log file at path \(file.path).")
  }
}

// MARK: - Constants

extension LogDestination {
  /// The destination for the console.
  public static let console = LogDestination(name: "console", logsToFile: false)
  
  /// The destination for debug-level messages.
  public static let debug = LogDestination(name: "debug", logsToFile: false)
  
  /// The destination for informational-level messages.
  public static let info = LogDestination(name: "info", logsToFile: true)
  
  /// The destination for notice-level messages.
  public static let notice = LogDestination(name: "notice", logsToFile: true)
  
  /// The destination for warning-level messages.
  public static let warning = LogDestination(name: "warning", logsToFile: true)
  
  /// The destination for error-level messages.
  public static let error = LogDestination(name: "error", logsToFile: true)
  
  /// The destination for critical-level messages.
  public static let critical = LogDestination(name: "critical", logsToFile: true)
  
  /// The destination for fatal-level messages.
  public static let fatal = LogDestination(name: "fatal", logsToFile: true)
}

// MARK: - Protocol Conformances

extension LogDestination: Codable { }

extension LogDestination: Equatable {
  public static func ==(lhs: LogDestination, rhs: LogDestination) -> Bool {
    lhs.consoleTag == rhs.consoleTag &&
    lhs.name == rhs.name &&
    lhs.file == rhs.file &&
    lhs.logsToFile == rhs.logsToFile
  }
}

extension LogDestination: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(consoleTag)
    hasher.combine(name)
    hasher.combine(file)
    hasher.combine(logsToFile)
  }
}
