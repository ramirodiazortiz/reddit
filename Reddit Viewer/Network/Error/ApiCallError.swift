//
//  ApiCallError.swift
//  reddit
//
//  Created by Ramiro Diaz on 31/08/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

enum ApiCallError: Error {
    case invalidUrl(_ url: String)
    case backend(statusCode: Int, model: [String: Any])
    case noData
    case noResponse
    case invalidJSONParsing(description: String)
    case unknown
}

extension ApiCallError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .invalidUrl(let url):
            return NSLocalizedString("InvalidUrlError", comment: "") + ": \(url)"
        case .backend(let code, let body):
			return NSLocalizedString("StatusCode", comment: "") + ": \(code)" +
				NSLocalizedString("ErrorDescription", comment: "") + ": \(body.description)"
		case .noData:
			 return NSLocalizedString("NoDataError", comment: "")
		case .noResponse:
			return NSLocalizedString("NoResponseError", comment: "")
		case .unknown:
            return NSLocalizedString("UnknownError", comment: "")
		case .invalidJSONParsing(let description):
			return NSLocalizedString("InvalidJSONParsing", comment: "") + ": \(description)"
        }
    }

}

extension ApiCallError: Equatable {

    static func == (lhs: ApiCallError, rhs: ApiCallError) -> Bool {
        switch (lhs, rhs) {
		case (.invalidUrl(let lurl), .invalidUrl(let rurl)):
			return lurl == rurl
        case (.unknown, .unknown),
             (.noResponse, .noResponse),
             (.noData, .noData),
             (.invalidJSONParsing, .invalidJSONParsing):
            return true
        case (.backend(let lStatusCode, _), .backend(let rStatusCode, _)):
            return lStatusCode == rStatusCode
        default:
            return false
        }
    }

}
