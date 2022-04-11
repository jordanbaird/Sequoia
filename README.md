# Sequoia

A simple, straightforward logging API. 

## Install

Add the following to your `Package.swift` file:

```swift
import PackageDescription

let package = Package(
    name: "PackageName",
    dependencies: [
        .package(url: "https://github.com/jordanbaird/Sequoia", from: "0.0.2")
    ],
    targets: [
        .target(
            name: "PackageName",
            dependencies: ["Sequoia"]
        )
    ]
)
```

## Usage

To log a message, either create an instance of `Log` by calling its `init(level:prints:)`
initializer, or by using one of its static methods, such as `info(_:)` or `warning(_:)`.

```swift
let logger = Log(level: .info, prints: true)
logger.log("A message.")

// Or...

Log.info("A message.")
```

You can also create your own custom log destinations, using one of the `LogDestination`
type's initializers. To log to a destination, create a `LogLevel` instance that uses it.

```swift
let destination = LogDestination(file: someURL, name: "CustomDestination", consoleTag: "Custom")

let level = LogLevel(destination: destination, description: "Custom", priority: 5)

let logger = Log(level: level)

logger.log("A message.")
```
