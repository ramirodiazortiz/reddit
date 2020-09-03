//
//  TopPostsListViewController.swift
//  reddit
//
//  Created by Ramiro Diaz on 31/08/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

//Note: I'm using a UIViewController instead of a UITableViewController since it has some issues wuth the safe areas
class TopPostsListViewController: UIViewController {
	
	typealias CompletionBlock = () -> Void
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet var topPostListFooter: TopPostListFooter!
	
	private let postListManager = PostListManager(
		requestExecutor: NetworkEnvironment.getExecutor,
		maxPosts: TopPostsListViewController.maxPosts
	)
	private let imageManager = ImageManager(requestExecutor: NetworkEnvironment.getImageExecutor)
	
	private static let pageSize = 10
	private static let maxPosts = 50

	override func viewDidLoad() {
		super.viewDidLoad()
		self.initRefreshControl()
		self.reloadData()
		self.topPostListFooter.setup(target: self, selector: #selector(onDismissAll))
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if let indexPath = tableView.indexPathForSelectedRow {
			tableView.deselectRow(at: indexPath, animated: false)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let navigation = segue.destination as? UINavigationController,
			let topViewController = navigation.topViewController as? PostDetailViewController,
			let indexPath = tableView.indexPathForSelectedRow {
			topViewController.post = postListManager[indexPath.row]
			topViewController.imageManger = imageManager
			topViewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
			topViewController.navigationItem.leftItemsSupplementBackButton = true
		}
	}

	private func reloadData(completionBlock: CompletionBlock? = nil) {
		topPostListFooter.hideDismissButton(hide: true)
		let currentPostsIds = Array(postListManager.postsIds)
		let current = postListManager.indexFor(postIds: currentPostsIds).compactMap { IndexPath(row: $0, section: 0) }
		postListManager.clearRepository()
		tableView.deleteRows(at: current, with: .right)
		postListManager.getPosts(pageSize: TopPostsListViewController.pageSize) { [weak self] (error)  in
			DispatchQueue.main.async {
				if error != nil {
					self?.showAlert(message: error?.errorDescription)
					self?.topPostListFooter?.hideLoader(hide: true)
					completionBlock?()
					return
				}
				self?.tableView.reloadSections(IndexSet(integer: 0), with: .top)
				completionBlock?()
			}
		}
	}
	
	private func fetchNextData() {
		topPostListFooter.swithToLoadingState(isLoading: true)
		postListManager.getNextPage(pageSize: TopPostsListViewController.pageSize) { [weak self] (newPosts, error, maxPostsReached) in
			guard let s = self else { return }
			if error != nil {
				self?.showAlert(message: error?.errorDescription)
				self?.topPostListFooter.swithToLoadingState(isLoading: false)
				return
			}
			let newPostsIndexPaths =
				s.postListManager.indexFor(postIds: newPosts).compactMap { IndexPath(row: $0, section: 0) }
			
			DispatchQueue.main.async {
				if !newPostsIndexPaths.isEmpty {
					self?.tableView.insertRows(at: newPostsIndexPaths, with: .automatic)
				}
				self?.topPostListFooter.swithToLoadingState(isLoading: false)
				if maxPostsReached {
					self?.showAlert(
						message: "\(NSLocalizedString("MaxPostsReached: ", comment: "")) \(TopPostsListViewController.maxPosts)"
					)
				}
			}
		}
	}
	
	private func showAlert(message: String?) {
		let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: message, preferredStyle: UIAlertController.Style.alert)
		alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { [weak alert] (action: UIAlertAction!) in
			alert?.dismiss(animated: true, completion: nil)
		})
		self.present(alert, animated: true, completion: nil)
	}
	
	private func dismissPost(postId: String) {
		if let index = postListManager.dismissPost(postId: postId) {
			tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .bottom)
		}
	}
	
	private func initRefreshControl() {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
		self.tableView.refreshControl = refreshControl
	}

	@objc private func onDismissAll() {
		postListManager.dismissAllPosts()
		tableView.reloadSections(IndexSet(integer: 0), with: .fade)
	}
	
	@objc private func refresh(_ sender: UIRefreshControl) {
		self.reloadData { [weak sender] in
			sender?.endRefreshing()
		}
	}

}

extension TopPostsListViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let id = postListManager[indexPath.row]?.id {
			postListManager.markPostAsRead(postId: id)
			let cell = tableView.cellForRow(at: indexPath) as! TopPostCell
			cell.markAsRead()
		}
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.tag = indexPath.row
		if postListManager.count == indexPath.row + 1, !postListManager.isRefreshing {
			fetchNextData()
		}
		if let post = postListManager[indexPath.row], let thumbnailUrlString = post.thumbnailUrl, let thumbnailUrl = URL(string: thumbnailUrlString) {
			imageManager.getImage(id: post.id, url: thumbnailUrl) { id, image in
				DispatchQueue.main.async { [weak cell, weak self] in
					//Guarantee we are updating the proper cell
					let postIndex = self?.postListManager.indexFor(postId: id)
					if let cell = cell as? TopPostCell, cell.tag == postIndex {
						cell.updateThumbnail(image: image)
					}
				}
			}
		}
	}
	
	func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let thumbnail = postListManager[indexPath.row]?.thumbnailUrl, let url = URL(string: thumbnail) {
			imageManager.cancelFetch(url: url)
		}
	}
}

extension TopPostsListViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return postListManager.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TopPostCell", for: indexPath) as! TopPostCell
		if let post = postListManager[indexPath.row] {
			cell.setup(
				postId: post.id,
				title: post.title,
				author: post.author,
				time: post.entryDate.relativeTime,
				numberOfComments: post.numberOfComments,
				wasRead: postListManager.getPostReadStatus(postId: post.id),
				onDismiss: { [unowned self] (postId) in
					self.dismissPost(postId: postId)
				}
			)
		}
		return cell
	}

	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		if postListManager.isEmpty, !postListManager.isRefreshing {
			let view = UIView()
			view.backgroundColor = .white
			return view
		} else if postListManager.isRefreshing {
			topPostListFooter.swithToLoadingState(isLoading: true)
			return topPostListFooter
		}
		topPostListFooter.swithToLoadingState(isLoading: false)
		return topPostListFooter
	}

	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if let id = postListManager[indexPath.row]?.id, editingStyle == .delete {
			self.dismissPost(postId: id)
		}
	}
}
