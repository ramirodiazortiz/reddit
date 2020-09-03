//
//  PostDetailViewController.swift
//  reddit
//
//  Created by Ramiro Diaz on 31/08/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit
import Photos

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
		addLongPressGesture()
	}

	@objc func handleGesture(_ sender: UILongPressGestureRecognizer) {
		if let image = imageView?.image, sender.state == .began {
			AlertHelper.showAlert(title: "Photo", message: "PhotoAsking", okText: "Ok", cancelText: "Cancel", okHandler: { [weak self] in
				self?.handleStatus(image: image, authorizationStatus: PHPhotoLibrary.authorizationStatus())
			}, presenter: self)
        }
	}

	private func handleStatus(image: UIImage, authorizationStatus: PHAuthorizationStatus) {
		switch authorizationStatus {
		case .denied, .restricted:
			AlertHelper.showOkAlert(title: "PermissionRequired", message: "PermissionRequiredText", presenter: self)
		case .authorized:
			UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
			AlertHelper.showOkAlert(title: "", message: "PhotoSaved", presenter: self)
		case .notDetermined:
			PHPhotoLibrary.requestAuthorization { [weak self] status in
				DispatchQueue.main.async {
					self?.handleStatus(image: image, authorizationStatus: status)
				}
			}
		default:
			AlertHelper.showOkAlert(title: "PermissionRequired", message: "PermissionRequiredText", presenter: self)
		}
	}
	
	private func addLongPressGesture() {
		let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
		longPressGesture.numberOfTapsRequired = 0
		longPressGesture.minimumPressDuration = 1.0
		imageView.isUserInteractionEnabled = true
		imageView?.addGestureRecognizer(longPressGesture)
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
	
	private func showPhotoLibraryPermissionAlert() {
		let alert = UIAlertController(
			title: NSLocalizedString("PermissionRequeired", comment: ""),
			message: NSLocalizedString("PermissionRequeiredText", comment: ""),
			preferredStyle: UIAlertController.Style.alert
		)
		alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.default) { [weak alert] (action: UIAlertAction!) in
			alert?.dismiss(animated: true, completion: nil)
		})
		self.present(alert, animated: true, completion: nil)
	}

	private func show() {
		let alert = UIAlertController(
			title: NSLocalizedString("PermissionRequeired", comment: ""),
			message: NSLocalizedString("PermissionRequeiredText", comment: ""),
			preferredStyle: UIAlertController.Style.alert
		)
		alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.default) { [weak alert] (action: UIAlertAction!) in
			alert?.dismiss(animated: true, completion: nil)
		})
		self.present(alert, animated: true, completion: nil)
	}
}

