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
	@IBOutlet weak var tapImageLabel: UILabel!
	@IBOutlet weak var longPressImageLabel: UILabel!
	
	var imageManger: ImageManager?
	
	var post: Post?

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
	}
	
	@objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
		if sender.state == .ended, let urlString = post?.picture, let url = URL(string: urlString)  {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
	}

	@objc func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
		if sender.state == .began {
			AlertHelper.showAlert(title: "Photo", message: "PhotoAsking", okText: "Ok", cancelText: "Cancel", okHandler: { [unowned self] in
				self.handleStatus(image: self.imageView.image!, authorizationStatus: PHPhotoLibrary.authorizationStatus())
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
		let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
		longPressGesture.numberOfTapsRequired = 0
		longPressGesture.minimumPressDuration = 1.0
		imageView?.addGestureRecognizer(longPressGesture)
	}
	
	private func addTapGesture() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
		tapGesture.numberOfTapsRequired = 2
		imageView?.addGestureRecognizer(tapGesture)
	}
	
	private func setupView() {
		guard let post = post else  {
			titleLabel?.text = nil
			authorLabel?.text = nil
			imageView?.image = nil
			longPressImageLabel?.isHidden = true
			tapImageLabel?.isHidden = true
			return
		}
		titleLabel?.text = post.title
		authorLabel?.text = post.author
		if let image = imageManger?.getLocalImage(id: post.id) {
			imageView?.image = image
			imageView.isUserInteractionEnabled = true
			if imageView.image != nil {
				longPressImageLabel.isHidden = false
				addLongPressGesture()
				if post.picture != nil {
					tapImageLabel.isHidden = false
					addTapGesture()
				}
			}
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

