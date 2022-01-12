//
//  APIResponseError.swift
//  
//
//  Created by Yuya Oka on 2022/01/12.
//

import Foundation

public struct APIResponseError: Swift.Error {
    // MARK: - Properties
    public let statusCode: StatusCode
    public let object: Any?

    // MARK: - Initialize
    public init(statusCode: Int, object: Any?) {
        self.statusCode = .init(code: statusCode)
        self.object = object
    }
}
