//
//  ResponseParseable.swift
//  reddit
//
//  Created by Ramiro Diaz on 31/08/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

protocol ResponseParseable {
	/**
	Required initializer that create a new instance.
	- parameter decoder: decoder used to decode the response.
	*/
    init(decoder: JSONDecoder)

	/**
	Method needed to parse a response, returning a model that conforms **Decodable** protocol.
	- parameter data: returned data provided by the async task
	- parameter response: url response of the request
	- parameter expectedType: type of an object implementing **Decodable** protocol.
	- parameter decodingStrategy: strategy of type **JSONDecoder.KeyDecodingStrategy** used to decode the model. Default is **.useDefaultKeys**

	- returns: The parsed model implementing **Decodable** protocol.
	*/
    func handleResponse<T: Decodable>(data: Data?, response: URLResponse?, expectedType: T.Type,
                                      decodingStrategy: JSONDecoder.KeyDecodingStrategy) throws -> T
}
