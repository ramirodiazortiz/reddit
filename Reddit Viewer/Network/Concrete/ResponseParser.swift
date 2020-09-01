//
//  ResponseParser.swift
//  reddit
//
//  Created by Ramiro Diaz on 31/08/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

/// Concrete implementation conforming **ResponseParseable** protocol.
struct ResponseParser: ResponseParseable {

    private let decoder: JSONDecoder

	/**
	Creates a response handler using alamofire
	- parameter decoder: decoder used to decode the response.
	Default is JSONDecoder.
	*/
    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

	/**
	Parses a response, returning a model that conforms **Decodable** protocol.
	- parameter response: response of type **DataResponse**.
	- parameter expectedType: type of an object implementing **Decodable** protocol.
	- parameter decodingStrategy: strategy of type **JSONDecoder.KeyDecodingStrategy**
	used to decode the model. Default is **.useDefaultKeys**
	
	- throws:
	    `APIClientError.noData` if **response** is data is null
	    `APIClientError.noResponse` when response can't be casted as HTTPURLResponse
		`APIClientError.unknown` when response status code is different than 200, but data can't be serialized as [String: Any].
		`APIClientError.backend` when response status code is different than 200 and data can be serialized as [String: Any].
		`APIClientError.invalidJSONParsing` when result is status code 200 but the decoder fails creating a model of **expectedType**.
	- returns: The parsed model implementing **Decodable** protocol.
	*/
	func handleResponse<T: Decodable>(data: Data?, response: URLResponse?, expectedType: T.Type,
                                      decodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) throws -> T {
        self.decoder.keyDecodingStrategy = decodingStrategy
        guard let data = data else {
            throw ApiCallError.noData
        }
		guard let response = response as? HTTPURLResponse else {
			throw ApiCallError.noResponse
		}
		if response.statusCode == 200 {
			do {
				return try decoder.decode(T.self, from: data)
			} catch (let error) {
				throw ApiCallError.invalidJSONParsing(description: error.localizedDescription)
			}
		} else {
			guard let errorData = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw ApiCallError.unknown
            }
            throw ApiCallError.backend(statusCode: response.statusCode, model: errorData)
		}
    }

}
