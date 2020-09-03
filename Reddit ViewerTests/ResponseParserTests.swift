//
//  ResponseParserTests.swift
//  reddit
//
//  Created by Ramiro Diaz on 03/09/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

@testable import Reddit_Viewer
import XCTest

class ResponseParserTests: XCTestCase {

    var parser: ResponseParser!

    override func setUp() {
        self.parser = ResponseParser(decoder: JSONDecoder())
    }

    func testValidParse() {
        var mockData: MockData?
		XCTAssertNoThrow(mockData = try? parser.handleResponse(data: successData, response: validHTTPURLResponse, expectedType: MockData.self, decodingStrategy: .useDefaultKeys))
		XCTAssertEqual(mockData?.var1, 1)
        XCTAssertEqual(mockData?.var2, 2)
    }

    func testInvalidJsonParsing() {
		XCTAssertThrowsError(
		try parser.handleResponse(
			data: successData,
			response: validHTTPURLResponse,
			expectedType: Int.self,
			decodingStrategy: .useDefaultKeys)
		) { error in
            XCTAssertEqual(error as? ApiCallError, ApiCallError.invalidJSONParsing(description: ""))
        }
    }

    func testInvalidData() {
		XCTAssertThrowsError(
		try parser.handleResponse(
			data: nil,
			response: validHTTPURLResponse,
			expectedType: Int.self,
			decodingStrategy: .useDefaultKeys)
		) { error in
            XCTAssertEqual(error as? ApiCallError, ApiCallError.noData)
        }
    }

    func testNoResponseData() {
		XCTAssertThrowsError(
		try parser.handleResponse(
			data: Data(),
			response: nil,
			expectedType: Int.self,
			decodingStrategy: .useDefaultKeys)
		) { error in
            XCTAssertEqual(error as? ApiCallError, ApiCallError.noResponse)
        }
    }
	
	func testBackendError() {
		let invalidLocation = "Invalid Location"
		let errorKey = "error"
		let error = [errorKey: invalidLocation]
		let jsonEncoder = JSONEncoder()
		guard let errorData = try? jsonEncoder.encode(error) else {
	            XCTFail("Error Data shouldn't be nil")
	            return
	        }
		let errorStatusCode = 400
		XCTAssertThrowsError(
		try parser.handleResponse(
			data: errorData,
			response: errorHTTPURLResponse(errorStatusCode),
			expectedType: Int.self,
			decodingStrategy: .useDefaultKeys)
		) { error in
            if case ApiCallError.backend(let statusCode, let errorData) = error {
				XCTAssertEqual(statusCode, errorStatusCode)
				XCTAssertEqual(errorData[errorKey] as? String, invalidLocation)
			} else {
				XCTFail("Invalid error type")
			}
        }
	}


    func testUnknownError() {
        let invalidLocation = "Invalid Location"
        let error = [CGFloat(100): invalidLocation]
        let jsonEncoder = JSONEncoder()
        guard let errorData = try? jsonEncoder.encode(error) else {
            XCTFail("Error Data shouldn't be nil")
            return
        }
		let errorStatusCode = 400
		XCTAssertThrowsError(
		try parser.handleResponse(
			data: errorData,
			response: errorHTTPURLResponse(errorStatusCode),
			expectedType: Int.self,
			decodingStrategy: .useDefaultKeys)
		) { error in
            XCTAssertEqual(error as? ApiCallError, ApiCallError.unknown)
		}
    }

	private var validHTTPURLResponse: HTTPURLResponse {
        return HTTPURLResponse(url: URL(string: "https://url.com")!, statusCode: 200, httpVersion: "",
                               headerFields: nil)!
    }
	
    private func errorHTTPURLResponse(_ statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: URL(string: "Url")!, statusCode: statusCode, httpVersion: "",
                               headerFields: nil)!
    }

    private var successData: Data {
		if let data = MockData(var1: 1, var2: 2).toData {
			return data
		}
		XCTFail("Neither data nor json should be nil")
		return Data()
    }

}

struct MockData: Codable {

    let var1: Int
    let var2: Int

    var toData: Data? {
        let jsonEncoder = JSONEncoder()
        return try? jsonEncoder.encode(self)
    }

}
