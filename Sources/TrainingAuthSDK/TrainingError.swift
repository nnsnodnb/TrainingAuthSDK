//
//  TrainingError.swift
//  
//
//  Created by Yuya Oka on 2022/01/12.
//

import Foundation

public enum TrainingError: Swift.Error {
    case existUser
    case noUser
    case failureAccessTokenRefresh
    case connection
    case request
    case nonHTTPURLResponse
    case unacceptableStatusCode(Int)
    case unexpectedObject(Any)
    case response(Error)
    case unknown(Error)
}
