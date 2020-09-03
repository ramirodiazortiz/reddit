//
//  TopPostCell.swift
//  reddit
//
//  Created by Ramiro Diaz on 01/09/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

class TopPostCell: UITableViewCell {

	typealias ActionBlock = ((String) -> Void)
	
	private var onDismiss: ActionBlock?
	private var postId: String!
	private let markAsReadAnimationDuration = 1.0
	
	@IBOutlet weak var thumbnailImageView: UIImageView!
	@IBOutlet weak var readStatusImageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var authorLabel: UILabel!
	@IBOutlet weak var numberOfCommentsLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!
	
	override func prepareForReuse() {
		super.prepareForReuse()
		self.readStatusImageView.alpha = 1.0
		self.thumbnailImageView.backgroundColor = .lightGray
		self.thumbnailImageView.image = UIImage(systemName: "arrow.clockwise.icloud")
	}

	func setup(postId: String, title: String, author: String, time: String, numberOfComments: Int, wasRead: Bool, onDismiss: ActionBlock?) {
		titleLabel.text = title
		authorLabel.text = author
		let keyNumberOfComments = numberOfComments > 1 ? "Comments" : "Comment"
		numberOfCommentsLabel.text = "\(numberOfComments) \(NSLocalizedString(keyNumberOfComments , comment: ""))"
		timeLabel.text = time
		self.readStatusImageView.isHidden = wasRead
		self.postId = postId
		self.onDismiss = onDismiss
	}

	func markAsRead() {
		UIView.animate(withDuration: markAsReadAnimationDuration, animations: {
			self.readStatusImageView.alpha = 0.0
		}, completion: { _ in
			self.readStatusImageView.isHidden = true
		})
	}
	
	func updateThumbnail(image: UIImage?) {
		if let image = image {
			self.thumbnailImageView.image = image
		}
		self.thumbnailImageView.backgroundColor = .clear
	}

	@IBAction func onDismissTouchUpInside() {
		self.onDismiss?(postId!)
	}

}
