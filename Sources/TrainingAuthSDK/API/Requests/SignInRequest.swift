//
//  SignInRequest.swift
//  
//
//  Created by Yuya Oka on 2022/01/12.
//

import APIKit
import Foundation

extension TrainingAPI {

    struct SignInRequest: TrainingRequestType {
        // MARK: - Response
        typealias Response = AccessToken

        // MARK: - Properties
        let baseURL: URL
        let method: HTTPMethod = .post
        let path: String = "/v1/users/sign-in"

        var parameters: Any? {
            return [
                "username": username,
                "password": password
            ]
        }

        private let username: String
        private let password: String

        // MARK: - Initialize
        init(baseURL: URL, username: String, password: String) {
            self.baseURL = baseURL
            self.username = username
            self.password = password
        }
    }
}
