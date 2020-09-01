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
	- parameter endpoint: endpoint conforming **Endpointable** protocol.
	- parameter expectedType: type of an object implementing **Decodable** protocol.
	*/
	func execute<T>(endpoint: Endpoint, with expectedType: T.Type, completionHandler: CompletionBlock<T>?) where T : Decodable {
		guard let url = endpoint.buildURL() else {
			completionHandler?(ApiCallResult.failure(.invalidUrl("\(endpoint.baseUrl) \(endpoint.path) \(endpoint.params.description)")))
			return
		}
		self.session = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
		self.task = self.session?.dataTask(with: url) { data, response, error in
			do {
				let parsedResponse =
					try self.responseHandler.handleResponse(
						data: data,
						response: response,
						expectedType: T.self,
						decodingStrategy: endpoint.keyDecodingStrategy
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
