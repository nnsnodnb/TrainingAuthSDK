//
//  APIError.swift
//  
//
//  Created by Yuya Oka on 2022/01/12.
//

import Foundation

public enum APIError: Swift.Error, CustomStringConvertible {
    case connectionError
    case requestError
    case nonHTTPURLResponse
    case unacceptableStatusCode(StatusCode)
    case unexpectedObject(Any)
    case responseError(APIResponseError)
    case unknownError(Error)

    // MARK: - Properties
    public var description: String {
        switch self {
        case .connectionError:
            return "Connection Error"
        case .requestError:
            return "URLSession Connection Error"
        case .nonHTTPURLResponse:
            return "Non HTTP URL Response"
        case .unacceptableStatusCode(let statusCode):
            return "Unacceptable Status Code \(statusCode.description)"
        case .unexpectedObject:
            return "Unexpected Object"
        case .responseError(let error):
            return "Response Error \(error.statusCode.description)"
        case .unknownError:
            return "Unknown Error"
        }
    }

    // MARK: - Initialize
    init(error: Error) {
        if let error = error as? SessionTaskError {
            switch error {
            case .connectionError:
                self = .connectionError
            case .requestError:
                self = .requestError
            case .responseError(let error as ResponseError):
                switch error {
                case .nonHTTPURLResponse:
                    self = .nonHTTPURLResponse
                case .unacceptableStatusCode(let statusCode):
                    self = .unacceptableStatusCode(.init(code: statusCode))
                case .unexpectedObject(let object):
                    self = .unexpectedObject(object)
                @unknown default:
                    self = .unknownError(error)
                }
            case .responseError(let error as APIResponseError):
                self = .responseError(error)
            case .responseError(let error):
                self = .unknownError(error)
            @unknown default:
                self = .unknownError(error)
            }
        } else {
            self = .unknownError(error)
        }
    }
}
