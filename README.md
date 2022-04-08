# Sequoia

A simple, yet powerful logger API. 

To log a message, either create an instance of `Log` by calling its `init(level:prints)`
initializer, or by ussing one of its pre-existing logging methods, such as `info(_:)` or
`warning(_:)`.

```swift
let logger = Log(level: .info, prints: true)
logger.log("A message.")

// Or...

Log.info("A message.")
```

You can also create your own custom log destinations, using one of the `LogDestination`
type's initializers. To log to this destination, create a `LogLevel` instance using the
destination.

```swift
let destination = LogDestination(file: someURL, name: "CustomDestination", consoleTag: "Custom")
let level = LogLevel(destination: destination, description: "Custom", priority: 5)
let logger = Log(level: level)
logger.log("A message.")
```
