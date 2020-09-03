//
//  PostDetailViewController.swift
//  reddit
//
//  Created by Ramiro Diaz on 31/08/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var authorLabel: UILabel!
	@IBOutlet weak var imageView: UIImageView!
	
	weak var imageManger: ImageManager?
	
	var post: Post? {
		didSet {
		    setupView()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
	}

	private func setupView() {
		guard let post = post else  {
			titleLabel?.text = nil
			authorLabel?.text = nil
			imageView?.image = nil
			return
		}
		titleLabel?.text = post.title
		authorLabel?.text = post.author
		if let image = imageManger?.getImageFromLocalCache(post.id) {
			self.imageView?.image = image
		} else {
			self.imageView?.image = UIImage(systemName: "arrow.clockwise.icloud")
		}
	}

}

