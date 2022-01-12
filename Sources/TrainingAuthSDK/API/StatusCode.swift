//
//  StatusCode.swift
//  
//
//  Created by Yuya Oka on 2022/01/12.
//

import Foundation

public enum StatusCode: Int {
    // MARK: - HTTP Errors
    case ok = 200
    case created = 201
    case accept = 202
    case noContent = 204

    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case notAcceptable = 406
    case requestTimeout = 408
    case payloadTooLarge = 413

    case internalServerError = 500
    case badGateway = 502
    case serviceUnavailable = 503
    case gatewayTimeout = 504

    case networkError = 0

    case unknowStatus = -1
    case objectParserError = 40400

    // MARK: - Initialize
    init(code: Int?) {
        if let code = code {
            self = StatusCode(rawValue: code) ?? .unknowStatus
        } else {
            self = .networkError
        }
    }
}

// MARK: - CustomStringConvertible
extension StatusCode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ok:
            return "OK"
        case .created:
            return "Created"
        case .accept:
            return "Accept"
        case .noContent:
            return "No Content"
        case .badRequest:
            return "Bad Request"
        case .unauthorized:
            return "Unauthorized"
        case .forbidden:
            return "Forbidden"
        case .notFound:
            return "Not Found"
        case .methodNotAllowed:
            return "Method Not Allowed"
        case .notAcceptable:
            return "Not Acceptable"
        case .requestTimeout:
            return "Request Timeout"
        case .payloadTooLarge:
            return "Payload Too Large"
        case .internalServerError:
            return "Internal Server Error"
        case .badGateway:
            return "Bad Gateway"
        case .serviceUnavailable:
            return "Service Unavailable"
        case .gatewayTimeout:
            return "Gateway Timeout"
        case .networkError:
            return "Network Error"
        case .unknowStatus:
            return "Unknown Status"
        case .objectParserError:
            return "Object Parser Error"
        }
    }
}
