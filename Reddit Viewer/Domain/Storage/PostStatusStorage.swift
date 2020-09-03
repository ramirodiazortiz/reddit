//
//  PostStatusStorage.swift
//  Reddit Viewer
//
//  Created by Ramiro Diaz on 01/09/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

class PostStatusStorage: NSObject {

	enum Key: String {
		case readStatus
		case dismissedStatus
	}
	
	private let cache: LocalStorage
	
	private var dismissPosts: [String]
	private var readPosts: [String]

	///Start the storage by using a complementary array to avoid accessing the LocalStorage every time
	init(cache: LocalStorage) {
		self.cache = cache
		readPosts = cache.getArray(key: Key.readStatus.rawValue, defaultValue: Array<String>())
		dismissPosts = cache.getArray(key: Key.dismissedStatus.rawValue, defaultValue: Array<String>())
	}
	
	/**
	Check the status of a single post
	- parameter postId: id of the post
	- returns:true if the post was read. Returns false otherwise
	*/
	func getPostReadStatus(postId: String) -> Bool {
		return readPosts.contains(postId)
	}

	/**
	Mark the status of a single post as read
	- parameter postId: id of the post
	*/
	func markPostAsRead(postId: String) {
		readPosts.append(postId)
		cache.setArray(readPosts, key: Key.readStatus.rawValue)
	}

	/**
	Check if a post was marked as dismissed
	- parameter postId: id of the post
	- returns:true if the post was marked as dismissed. Returns false otherwise
	*/
	func getPostDismissedStatus(postId: String) -> Bool {
		return dismissPosts.contains(postId)
	}

	/**
	Mark the status of a single post as dismissed
	- parameter postId: id of the post
	*/
	func markPostAsDismissed(postId: String) {
		dismissPosts.append(postId)
		cache.setArray(dismissPosts, key: Key.dismissedStatus.rawValue)
	}

	/**
	Mark the status of a each post in the list as dismissed
	- parameter postIds: list containing the id of each post
	*/
	func markPostAsDismissed(postIds: [String]) {
		dismissPosts.append(contentsOf: postIds)
		cache.setArray(dismissPosts, key: Key.dismissedStatus.rawValue)
	}

}
