//
//  LocalStorageTests.swift
//  reddit
//
//  Created by Ramiro Diaz on 03/09/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

@testable import Reddit_Viewer
import XCTest

class LocalStorageTests: XCTestCase {
	
	func testEmptyCache() {
		let localCache = LocalStorage(storage: UserDefaults(suiteName: "LocalStorageTests.empty")!)
		let array = localCache.getArray(key: "Key", defaultValue: [])
		XCTAssertTrue(array.isEmpty)
	}
	
	func testGet() {
		let key = "Key"
		let value = ["test"]
		let defaults = UserDefaults(suiteName: "LocalStorageTests.get")!
		defaults.set(value, forKey: key)
		let localCache = LocalStorage(storage: defaults)
		let array = localCache.getArray(key: key, defaultValue: [])
		XCTAssertTrue(!array.isEmpty)
		XCTAssertEqual(value, value)
	}
	
	func testSave() {
		let key = "Key"
		let value = ["test"]
		let defaults = UserDefaults(suiteName: "LocalStorageTests.save")!
		let localCache = LocalStorage(storage: defaults)
		localCache.setArray(value, key: key)
		let array = localCache.getArray(key: key, defaultValue: []) as! [String]
		XCTAssertTrue(!array.isEmpty)
		XCTAssertEqual(array, value)
		
	}

}
