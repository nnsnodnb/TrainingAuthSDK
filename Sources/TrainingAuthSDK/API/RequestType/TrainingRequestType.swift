//
//  TrainingRequestType.swift
//  
//
//  Created by Yuya Oka on 2022/01/12.
//

import APIKit
import Foundation

protocol TrainingRequestType: Request {}

extension TrainingRequestType {
    var dataParser: DataParser { return DecodableJSONDataParser() }

    func intercept(urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.timeoutInterval = 20
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        return urlRequest
    }

    func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        switch urlResponse.statusCode {
        case 200..<300:
            return object
        case 400:
            throw APIResponseError(statusCode: urlResponse.statusCode, object: object)
        default:
            throw ResponseError.unacceptableStatusCode(urlResponse.statusCode)
        }
    }
}

extension TrainingRequestType where Response: Decodable {
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let data = object as? Data else { throw ResponseError.unexpectedObject(object) }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Response.self, from: data)
    }
}
