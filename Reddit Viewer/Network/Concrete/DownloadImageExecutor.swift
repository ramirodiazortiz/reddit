//
//  DownloadImageExecutor.swift
//  reddit
//
//  Created by Ramiro Diaz on 02/09/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

/// Concrete implementation of RequestExectuable using URLSession
class DownloadExecutor: NSObject, RequestExecutable {
	
    private let session: URLSession
	private var tasks = [URLSessionTask]()

    init(configuration: URLSessionConfiguration = .default) {
		self.session = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
        super.init()
    }

	/**
	Executes a download data request
	- parameter url: url to request
	- parameter expectedType: type of an object implementing **Decodable** protocol.
	- parameter decodingStrategy: ignored.
	- parameter completionHandler: the completion handler dispatched when the request finishes.
	 This handler includes an api result object, that can either be .success (including the parsed object) or failure (including ApiCallError data)
	Note: the same executor can't execute multiple tasks at the same time.
	*/
	func execute<T>(url: URL, decodingStrategy: JSONDecoder.KeyDecodingStrategy?, with expectedType: T.Type, completionHandler: ((ApiCallResult<T, ApiCallError>) -> Void)?) where T : Decodable {
		let task = session.downloadTask(with: url) { [weak self] (url, response, error) in
			guard let fileURL = url as? T else {
				completionHandler?(ApiCallResult.failure(.invalidUrl(url?.absoluteString ?? "")))
				return
			}
			self?.tasks.removeAll(where: { $0.originalRequest?.url == url })
			completionHandler?(ApiCallResult.success(fileURL))
		}
		tasks.append(task)
		task.resume()
	}

	/**
	Method to cancel a request
	- parameter url: url of the request to cancel
	*/
	func cancel(url: URL) {
		if let task = self.tasks.first(where: { $0.originalRequest?.url == url }) {
			task.cancel()
		}
    }

}
