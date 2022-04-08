//===----------------------------------------------------------------------===//
//
// Lock.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

import Foundation

@usableFromInline
struct Lock {
  private let recursiveLock = NSRecursiveLock()
  
  @usableFromInline
  @inline(__always)
  func lock() {
    recursiveLock.lock()
  }
  
  @usableFromInline
  @inline(__always)
  func unlock() {
    recursiveLock.unlock()
  }
  
  @usableFromInline
  @inline(__always)
  @discardableResult
  func synchronize<T>(_ block: () throws -> T) rethrows -> T {
    lock()
    defer {
      unlock()
    }
    return try block()
  }
}
