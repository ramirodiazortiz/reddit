//
//  CollectionEndpointsTest.swift
//  Reddit ViewerTests
//
//  Created by Ramiro Diaz on 03/09/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

@testable import Reddit_Viewer
import XCTest

class CollectionEndpointsTest: XCTestCase {

    func testGetParameters() {
		let limit = 50
		let after = "afterId"
		let endpoint = CollectionEndpoints.topPosts(limit: limit, after: after)
		let params = endpoint.params
		XCTAssertTrue(params?["limit"] as? Int == limit)
		XCTAssertTrue(params?["after"] as? String == after)
	}
	
	func testUrlPaginationParameters() {
		let limit = 50
		let endpoint = CollectionEndpoints.topPosts(limit: limit, after: nil)
		let params = endpoint.params
		XCTAssertTrue(params?["limit"] as? Int == limit)
		XCTAssertTrue(params?["after"] == nil )
	}
	
	func testPathParameter() {
		let endpoint = CollectionEndpoints.topPosts(limit: 50, after: "")
		XCTAssertEqual(endpoint.path, "/top.json")
	}

	func testBuildURL() {
		let endpoint1 = CollectionEndpoints.topPosts(limit: 50, after: "name")
		let endpoint2 = CollectionEndpoints.topPosts(limit: 50, after: nil)
		let endpoint2Url = endpoint1.buildURL()
		XCTAssertTrue(
			endpoint2Url?.absoluteString == URL(string: "https://www.reddit.com/top.json?after=name&limit=50")!.absoluteString ||
			endpoint2Url?.absoluteString == URL(string: "https://www.reddit.com/top.json?limit=50&after=name")!.absoluteString
		)
		XCTAssertTrue(endpoint2.buildURL()?.absoluteString == URL(string: "https://www.reddit.com/top.json?limit=50")?.absoluteString)
	}
}
