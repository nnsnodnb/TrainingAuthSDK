//
//  RefreshTokenRequest.swift
//  
//
//  Created by Yuya Oka on 2022/01/12.
//

import APIKit
import Foundation

extension TrainingAPI {
    struct RefreshTokenRequest: TrainingRequestType {
        // MARK: - Response
        typealias Response = RefreshToken

        // MARK: - Properties
        let baseURL: URL
        let method: HTTPMethod = .post
        let path: String = "/v1/users/refresh"

        var parameters: Any? {
            return [
                "refresh": refreshToken
            ]
        }

        private let refreshToken: String

        // MARK: - Initialize
        init(baseURL: URL, refreshToken: String) {
            self.baseURL = baseURL
            self.refreshToken = refreshToken
        }
    }
}
