//
//  Endpoint.swift
//  reddit
//
//  Created by Ramiro Diaz on 31/08/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

///Protocol conformance required to execute requests using a RequestExecutable instance.
protocol Endpoint {
	///Base url of an specific endpoint
    var baseUrl: String { get }
	///path of an specific endpoint.
	var path: String { get }
	///Parameters of an specific endpoint.
	var params: [String: Any] { get }
	///Returns  a full url, joining all the relevant parts
    func buildURL() -> String
	///Decoding strategy used for the specific endpoint.
	var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get }
}
