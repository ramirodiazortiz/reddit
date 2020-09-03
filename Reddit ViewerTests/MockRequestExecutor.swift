//
//  MockRequestExecutor.swift
//  reddit
//
//  Created by Ramiro Diaz on 03/09/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

@testable import Reddit_Viewer
import UIKit

class MockRequestExecutor: RequestExecutable {
	
	private let parser: ResponseParseable
	private let bundle: Bundle

	init(bundle: Bundle = .main, responseHandler: ResponseParseable) {
		self.bundle = bundle
        self.parser = responseHandler
    }
	
	func execute<T>(url: URL, decodingStrategy: JSONDecoder.KeyDecodingStrategy?, with expectedType: T.Type, completionHandler: ((ApiCallResult<T, ApiCallError>) -> Void)?) where T : Decodable {
		var fileName = "top"
		if let page = url.query?.toQueryDictionary["after"] {
			fileName = fileName + "_after_\(page)"
		}
		
		let resource = bundle.url(forResource: fileName, withExtension: "json", subdirectory: "MockData/")
		let response = HTTPURLResponse(url: URL(string: "https://url.com")!, statusCode: 200, httpVersion: "",
		headerFields: nil)!
		do {
			let data = try? Data(contentsOf: resource!)
			let parsedResponse = try? parser.handleResponse(data: data, response: response, expectedType: PostList.self, decodingStrategy: decodingStrategy ?? .useDefaultKeys)
			completionHandler?(ApiCallResult.success(parsedResponse as! T))
		}
	}

	func cancel(url: URL) {}
	
	
}
