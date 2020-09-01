//
//  RequestExecutable.swift
//  reddit
//
//  Created by Ramiro Diaz on 31/08/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

///Interface required to implement a request executor.
protocol RequestExecutable {
	/**
	Method to start running a request  based on a url
	- parameter endpoint: endpoint associated to the request (implementing endpoint interface)
	- parameter expectedType: expected type of the object after parsing the data
	- parameter completionHandler: the completion handler dispatched when the request finishes.
	This handler includes an api result object, that can either be .success (including the parsed object) or failure (including ApiCallError data)
   */
	func execute<T: Decodable>(endpoint: Endpoint, with expectedType: T.Type, completionHandler: ((ApiCallResult<T, ApiCallError>) -> Void)?) -> Void

	///Method to cancel current request
    func cancel()
}
