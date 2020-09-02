//
//  RequestExecutor.swift
//  Reddit Viewer
//
//  Created by Ramiro Diaz on 31/08/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

/// Concrete implementation conforming **RequestExecutable** protocol using NSURLSession
class RequestExecutor: RequestExecutable {
	
	typealias CompletionBlock<T> = (ApiCallResult<T, ApiCallError>) -> Void
	
	private let configuration: URLSessionConfiguration
	private let responseHandler: ResponseParseable
	private var session: URLSession?
	private weak var task: URLSessionTask?

	/**
	Creates a request executor
	- parameter configuration: URLSessionConfiguration object used to create the url session.
	- parameter responseHandler: handler conforming **ResponseParseable** used to parse the response.
	*/
    init(configuration: URLSessionConfiguration = .default, responseHandler: ResponseParseable) {
        self.configuration = configuration
		self.responseHandler = responseHandler
    }

	/**
	Executes a request, parsing the received data using the response handler.
	- parameter url: url to request
	- parameter expectedType: type of an object implementing **Decodable** protocol.
	- parameter decodingStrategy: strategy of type **JSONDecoder.KeyDecodingStrategy**
	used to decode the model. Default is **.useDefaultKeys**
	- parameter completionHandler: the completion handler dispatched when the request finishes.
	 This handler includes an api result object, that can either be .success (including the parsed object) or failure (including ApiCallError data)
	*/

	func execute<T>(url: URL, decodingStrategy: JSONDecoder.KeyDecodingStrategy?, with expectedType: T.Type, completionHandler: CompletionBlock<T>?) where T : Decodable {
		self.session = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
		self.task = self.session?.dataTask(with: url) { [weak self] data, response, error in
			do {
				guard let s = self else { return }
				let parsedResponse =
					try s.responseHandler.handleResponse(
						data: data,
						response: response,
						expectedType: T.self,
						decodingStrategy: decodingStrategy ?? .useDefaultKeys
				)
				let result = ApiCallResult<T, ApiCallError>.success(parsedResponse)
				completionHandler?(result)
			} catch let error where error is ApiCallError {
				let result = ApiCallResult<T, ApiCallError>.failure(error as! ApiCallError)
				completionHandler?(result)
			} catch {
				completionHandler?(ApiCallResult.failure(.unknown))
			}
		}
        task?.resume()
	}

	/// Method used to cancel the current request (if any).
    func cancel() {
        task?.cancel()
        task = nil
        session?.invalidateAndCancel()
        session = nil
    }

}
