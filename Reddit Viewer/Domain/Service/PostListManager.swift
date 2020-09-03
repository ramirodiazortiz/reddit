//
//  PostListManager.swift
//  reddit
//
//  Created by Ramiro Diaz on 01/09/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

///Manages the current list of the posts
class PostListManager: NSObject {

	typealias CompletionBlock = (ApiCallError?) -> Void
	typealias NewPageCompletionBlock = ([String], ApiCallError?, Bool) -> Void
	
	private(set) var topPosts = [Post]()
	private let statusStorage = PostStatusStorage()
	private let executor: RequestExecutable
	private let maxPosts: Int
	
	var isRefreshing = false
	/**
	Initialize the manager.
	- parameter requestExecutor: concrete object implementing RequestExecutable interface
	- parameter maxItems: maximum number of posts
	*/
	init(requestExecutor: RequestExecutable, maxPosts: Int) {
		self.executor = requestExecutor
		self.maxPosts = maxPosts
	}
	/**
	Get  posts from the server. This metthod will remove from the answer those posts marked as dismissed.  It will also attempt to fulfil the pageSize limit by calling itself recursively. If the number of elements returned by the endpoint is 0, it will break the execution. If the Api call faills, the error will be reported in the completion block. We don't look fetch new posts if maxPosts was reached
	- parameter pageSize: desired ammount of posts
	- parameter afterId: id of a post. When passed this parameter, we will only find elements after this one
	- parameter completion:callback when the task is done.
	*/
	func getPosts(pageSize: Int, afterId: String? = nil, completion: @escaping CompletionBlock) {
		let realPageSize = min(pageSize, maxPosts - topPosts.count)
		if realPageSize == 0 {
			return
		}
		isRefreshing = true
		let endpoint = CollectionEndpoints.topPosts(limit: realPageSize, after: afterId)
		executor.execute(url: endpoint.buildURL()!, decodingStrategy: endpoint.keyDecodingStrategy, with: PostList.self) { [weak self] (result) in
			switch result {
				case .success(let list):
					self?.checkLimit(list.data, limit: realPageSize, completion: completion)
				case .failure(let error):
					completion(error)
			}
		}
	}
	
	/**
	Get  posts from the server. This metthod will remove from the answer those posts marked as dismissed.  It will also attempt to fulfil the pageSize limit by calling itself recursively. If the number of elements returned by the endpoint is 0, it will break the execution. If the Api call faills, the error will be reported in the completion block. It uses last post id as 
	- parameter pageSize: desired ammount of posts
	- parameter completion:callback when the task is done. Returns, the new posts ids, the error, if any and a boolean indicating whether maxPosts was reached
	*/
	func getNextPage(pageSize: Int, completion: @escaping NewPageCompletionBlock) {
		let realPageSize = min(pageSize, maxPosts - topPosts.count)
		if realPageSize == 0 {
			completion([], nil, true)
			return
		}
		let oldPostIds = self.postsIds
		getPosts(pageSize: realPageSize, afterId: topPosts.last?.id) { [weak self] (error) in
			guard let s = self else {
				completion([], error, false)
				return
			}
			completion(Array(s.postsIds.subtracting(oldPostIds)), error, false)
		}
	}
	
	/**
	Updates the topPosts list by removing the post., Also marks the post as dismissed in the cache.
	- parameter postId: id of the post
	- returns:the position of the element in  topPosts if any. If not, it returns nil
	*/
	func dismissPost(postId: String) -> Int? {
		statusStorage.markPostAsDismissed(postId: postId)
		if let index = topPosts.firstIndex(where: { $0.id == postId }) {
			topPosts.remove(at: index)
			return index
		}
		return nil
	}

	/**
	Updates the topPosts list by removing all the elements., Also marks all the post as dismissed in the cache.
	*/
	func dismissAllPosts() {
		statusStorage.markPostAsDismissed(postIds: topPosts.compactMap { $0.id } )
		topPosts.removeAll()
	}

	/**
	Marks the post as read in the cache.
	- parameter postId: id of the post
	*/
	func markPostAsRead(postId: String) {
		statusStorage.markPostAsRead(postId: postId)
	}

	/**
	Get the read status of the post in the cache
	- parameter postId id of the post
	- returns:true if the post was read. Returns false otherwise
	*/
	func getPostReadStatus(postId: String) -> Bool {
		return statusStorage.getPostReadStatus(postId: postId)
	}

	///Returns true if  topPosts is empty
	var isEmpty: Bool {
		return topPosts.isEmpty
	}
	
	///Returns the number of elements in topPosts
	var count: Int {
		return topPosts.count
	}

	///Returs a set containing the id off all the posts
	var postsIds: Set<String> {
		return Set(topPosts.compactMap { $0.id })
	}
	/**
	Given a page of posts, it removes the elements that were already dismissed.
	- parameter page list of elements retrieved by the server
	- returns:the list of posts, excluding those elements already dismissed
	*/
	private func filterNotDismissedPosts(_ page: [Post]) -> [Post] {
		return page.filter { !statusStorage.getPostDismissedStatus(postId: $0.id) && !topPosts.contains($0) }
	}
	
	/**
	Checks if  a page fulfils the limit condition. If the page has 0 elements, it calls the completion block. If the page (excluding the elements already
	dismissed) fulfils the limit condition, it calls the completion block. If not, It tries to get the remaining elements in a new call
	- parameter page list of elements retrieved by the server
	- parameter completion callback when the task is done
	*/
	private func checkLimit(_ page: [Post], limit: Int, completion: @escaping CompletionBlock) {
		if page.isEmpty {
			completion(nil)
			isRefreshing = false
		}
		let filteredPage = filterNotDismissedPosts(page)
		topPosts.append(contentsOf: filteredPage)
		if filteredPage.count >= limit {
			completion(nil)
			isRefreshing = false
		} else {
			let newLimit = limit - filteredPage.count
			if let lastId = page.last?.id {
				getPosts(pageSize: newLimit, afterId: lastId,  completion: completion)
			} else {
				completion(nil)
				isRefreshing = false
			}
		}
		
	}

	subscript(index: Int) -> Post? {
		if topPosts.count > index {
			return topPosts[index]
		}
		return nil
    }

	///Returns the index of the post in topPosts array
	func indexFor(postId: String) -> Int? {
		return topPosts.firstIndex { postId == $0.id }
	}

	///Returns the index list of the posts in topPosts array (sorted ASC)
	func indexFor(postIds: [String]) -> [Int] {
		return postIds.compactMap { indexFor(postId: $0) }.sorted()
	}
	
	///Removes all the items in the top posts array
	func clearRepository() {
		topPosts.removeAll()
	}

}
