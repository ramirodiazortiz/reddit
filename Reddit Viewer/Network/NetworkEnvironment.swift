//
//  NetworkEnvironment.swift
//  reddit
//
//  Created by Ramiro Diaz on 31/08/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

class NetworkEnvironment {
	
	static var getExecutor: RequestExecutable {
		let configuration = URLSessionConfiguration.default
		configuration.timeoutIntervalForRequest = 20
		configuration.waitsForConnectivity = true
		return RequestExecutor(configuration: configuration, responseHandler: ResponseParser())
	}

}

///provide default implementations for some of the Endpointable interfaces.
extension Endpoint {

	///Returns a url using .serverUrl defined in the main bundle info.plist file.
    var baseUrl: String {
		return "www.reddit.com"
    }

	///Returns a url by concatenating baseUrl + path +  params properties.
    func buildURL() -> URL? {
		var components = URLComponents()
		components.scheme = scheme
		components.host = baseUrl
		components.path = path
		components.queryItems = params.toQueryItems
		return components.url
    }

	///Returns "convertFromSnakeCase" as default keyDecodingStrategy.
	var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy {
		return .useDefaultKeys
	}
	
	///Scheme used in the url request
	var scheme: String {
		return "https"
	}

}
