//
//  PostListManagerTests.swift
//  reddit
//
//  Created by Ramiro Diaz on 03/09/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

@testable import Reddit_Viewer
import XCTest

class PostListManagerTests: XCTestCase {
	
	var manager: PostListManager!
	
	override func setUp() {
		let executor = MockRequestExecutor(bundle: Bundle(for: PostListManagerTests.self), responseHandler: ResponseParser())
        self.manager = PostListManager(requestExecutor: executor, maxPosts: 10)
    }

    func testGet5Posts() {
		let expectation = self.expectation(description: "Getting Data")
		manager.getPosts(pageSize: 5) { error, _ in
			expectation.fulfill()
			XCTAssertEqual(error, nil)
			XCTAssertEqual(self.manager.count, 5)
			let post = self.manager[0]
			XCTAssertEqual(post?.id, "t3_ilmcdl")
			XCTAssertEqual(post?.numberOfComments, 2287)
			XCTAssertEqual(post?.title, "Is it flat enough ?")
			XCTAssertEqual(post?.thumbnailUrl, "https://b.thumbs.redditmedia.com/wBK-nAV2VWcAXxGt5dW8-UjqI7wiHGpKNOzkfo2YJNc.jpg")
			XCTAssertEqual(post?.picture, nil)
		}
		waitForExpectations(timeout: 10, handler: nil)
    }

	func testEndReached() {
		let expectation = self.expectation(description: "Getting Data")
		manager.getPosts(pageSize: 5) { error, _  in
			self.manager.getNextPage(pageSize: 1, completion: { (newPosts, error, end) in
				expectation.fulfill()
				XCTAssertTrue(end)
			})
		}
		waitForExpectations(timeout: 10, handler: nil)
    }
	
}

