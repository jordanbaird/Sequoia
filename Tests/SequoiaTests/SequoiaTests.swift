//===----------------------------------------------------------------------===//
//
// SequoiaTests.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

import os
import XCTest
@testable import Sequoia

class LogTests: XCTestCase {
  func testConsole() {
    try? Log.delete(.console)
    XCTAssert(!Log(level: .console).destination.fileExists)
    Log.console("Testing console.")
    Thread.sleep(forTimeInterval: 0.1)
    XCTAssert(!Log(level: .console).destination.fileExists)
  }
  
  func testDebug() {
    try? Log.delete(.debug)
    XCTAssert(!Log(level: .debug).destination.fileExists)
    Log.debug("Testing debug.")
    Thread.sleep(forTimeInterval: 0.1)
    XCTAssert(!Log(level: .debug).destination.fileExists)
  }
  
  func testInfo() {
    try? Log.delete(.info)
    XCTAssert(!Log(level: .info).destination.fileExists)
    Log.info("Testing info.")
    Thread.sleep(forTimeInterval: 0.1)
    XCTAssert(Log(level: .info).destination.fileExists)
  }
  
  func testWarning() {
    try? Log.delete(.warning)
    XCTAssert(!Log(level: .warning).destination.fileExists)
    Log.warning("Testing warning.")
    Thread.sleep(forTimeInterval: 0.1)
    XCTAssert(Log(level: .warning).destination.fileExists)
  }
  
  func testError() {
    try? Log.delete(.error)
    XCTAssert(!Log(level: .error).destination.fileExists)
    Log.error("Testing error.")
    Thread.sleep(forTimeInterval: 0.1)
    XCTAssert(Log(level: .error).destination.fileExists)
  }
  
  func testCritical() {
    try? Log.delete(.critical)
    XCTAssert(!Log(level: .critical).destination.fileExists)
    Log.critical("Testing critical.")
    Thread.sleep(forTimeInterval: 0.1)
    XCTAssert(Log(level: .critical).destination.fileExists)
  }
  
  func testCustom() {
    try? Log.delete(.custom(higherThan: .critical))
    XCTAssert(!Log(level: .custom(higherThan: .critical)).destination.fileExists)
    Log(level: .custom(higherThan: .critical, description: "SUPER CRITICAL")).logAsync("Testing custom.")
    Thread.sleep(forTimeInterval: 0.1)
    XCTAssert(Log(level: .custom(higherThan: .critical)).destination.fileExists)
  }
  
  func testLogAsync() {
    Log(level: .info).logAsync("Testing async.")
    Thread.sleep(forTimeInterval: 0.1)
    XCTAssert(Log.read(.info).hasSuffix("Testing async.\n"))
  }
  
  func testLogSync() {
    Log(level: .info).logSync("Testing sync.")
    XCTAssert(Log.read(.info).hasSuffix("Testing sync.\n"))
  }
  
  // -- Speed Tests -- //
  
  func testOSLogSpeed() {
    measure {
      os_log("Testing speed.", type: .debug)
    }
  }
  
  func testLogSpeed() {
    measure {
      Log.debug("Testing speed.")
    }
  }
}
