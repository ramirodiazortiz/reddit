//
//  ImageManager.swift
//  reddit
//
//  Created by Ramiro Diaz on 02/09/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

//TODO: Add unit tests
class ImageManager: NSObject {

	typealias CompletionBlock = (String, UIImage?) -> Void

	private let executor: RequestExecutable
	private let localCache = NSCache<NSString, UIImage>()

	init(requestExecutor: RequestExecutable) {
		self.executor =  requestExecutor
	}

	/**
	Get an image from a url. This method will attempt the image from the local cache. If that fails, it will look for the image in the disk. Otherwise, it executes the request.
	- parameter id: id to identify the image
	- parameter url: url of the image
	- parameter completion callback returning the original id and the image, if any
	*/
	func getImage(id: String, url: URL, completionHandler: CompletionBlock?) {
		if let image = getLocalImage(id: id) {
			completionHandler?(id, image)
			return
		} else if let storedImagePath = storeImagePath(id) {
			executor.execute(url: url, decodingStrategy: nil, with: URL.self) { [weak self] result in
				switch result {
				case .success(let url):
					try? FileManager.default.moveItem(at: url, to: storedImagePath)
					if let image = self?.getImageFromDisk(storedImagePath) {
						self?.setImageInLocalCache(image, using: id)
						completionHandler?(id, image)
					} else {
						completionHandler?(id, nil)
					}
				case .failure(_):
					completionHandler?(id, nil)
				}
			}
		}
		completionHandler?(id, nil)
	}
	
	/**
	Get an image locally. If first trying using the cache. Then tries the disk. Else, returns nil
	- parameter id: id to identify the image
	*/
	func getLocalImage(id: String) -> UIImage? {
		if let image = getImageFromLocalCache(id) {
			return image
		} else if let storedImagePath = storeImagePath(id), let image = getImageFromDisk(storedImagePath) {
			return image
		}
		return nil
	}
	
	/**
	Uses the executor to cancel the request using its url
	- parameter url: url to cancel
	*/
	func cancelFetch(url: URL) {
		executor.cancel(url: url)
	}
	
	/**
	Get an image from the local cache, using it's id
	- parameter id: id to identify the image
	- returns: returns the image or nil
	*/
	private func getImageFromLocalCache(_ id: String) -> UIImage? {
		return localCache.object(forKey: NSString(string: id))
	}

	/**
	Updates the local cache
	- parameter image: image to store in the local cache
	- parameter id: id used to identify the image
	*/
	private func setImageInLocalCache(_ image: UIImage, using id: String) {
		localCache.setObject(image, forKey: NSString(string: id))
	}
	
	///Returns the url of the local file
	private func storeImagePath(_ id: String) -> URL? {
		let documentsURL = try? FileManager.default.url(for: .documentDirectory,
												in: .userDomainMask,
												appropriateFor: nil,
												create: false)
		return documentsURL?.appendingPathComponent(id)
	}
	
	/**
	Returns the image from the disk located at url.
	- parameter url: url of the image in the disk
	- returns: the image located at the url or nil.
	*/
	private func getImageFromDisk(_ url: URL) -> UIImage? {
		if !FileManager.default.fileExists(atPath: url.path) {
			return nil
		}
		if let data = try? Data(contentsOf: url) {
			return UIImage(data: data)
		}
		return nil
	}
	
	deinit {
		print("")
	}
}
