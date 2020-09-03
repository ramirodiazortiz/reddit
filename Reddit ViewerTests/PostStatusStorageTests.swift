//
//  PostStatusStorageTests.swift
//  reddit
//
//  Created by Ramiro Diaz on 03/09/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

@testable import Reddit_Viewer
import XCTest

class PostStatusStorageTests : XCTestCase {
	
	func testReadPosts() {
		let defaults =  UserDefaults(suiteName: "LocalStorageTests.read")!
		defaults.set(["read1"], forKey: PostStatusStorage.Key.readStatus.rawValue)
		let localCache = LocalStorage(storage:defaults)
		let storage = PostStatusStorage(cache: localCache)
		XCTAssertFalse(storage.getPostReadStatus(postId: "read2"))
		XCTAssertTrue(storage.getPostReadStatus(postId: "read1"))
	}
	
	func testDismissedPosts() {
		let defaults =  UserDefaults(suiteName: "LocalStorageTests.dismissed")!
		defaults.set(["dismissed1"], forKey: PostStatusStorage.Key.dismissedStatus.rawValue)
		let localCache = LocalStorage(storage:defaults)
		let storage = PostStatusStorage(cache: localCache)
		XCTAssertFalse(storage.getPostDismissedStatus(postId: "dismissed2"))
		XCTAssertTrue(storage.getPostDismissedStatus(postId: "dismissed1"))
	}
	
	func testMarkRead() {
		let defaults =  UserDefaults(suiteName: "LocalStorageTests.read.mark")!
		let localCache = LocalStorage(storage:defaults)
		let storage = PostStatusStorage(cache: localCache)
		storage.markPostAsRead(postId: "read1")
		storage.markPostAsDismissed(postId: "read2")
		let array = defaults.array(forKey: PostStatusStorage.Key.readStatus.rawValue) as! [String]
		XCTAssertFalse(array.contains("read2"))
		XCTAssertTrue(array.contains("read1"))
	}
	
	func testMarkDismissed() {
		let defaults =  UserDefaults(suiteName: "LocalStorageTests.dismissed.mark")!
		let localCache = LocalStorage(storage:defaults)
		let storage = PostStatusStorage(cache: localCache)
		storage.markPostAsDismissed(postId: "dismissed1")
		storage.markPostAsRead(postId: "dismissed2")
		let array = defaults.array(forKey:PostStatusStorage.Key.dismissedStatus.rawValue) as! [String]
		XCTAssertFalse(array.contains("dismissed2"))
		XCTAssertTrue(array.contains("dismissed1"))
	}

}
