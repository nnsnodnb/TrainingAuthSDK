//
//  Auth.swift
//  
//
//  Created by Yuya Oka on 2022/01/12.
//

import APIKit
import Foundation

public final class Auth {
    // MARK: - Properties
    public var isLoggedIn: Bool {
        return secretStoreService.accessToken != nil
    }

    private let baseURL: URL
    private let secretStoreService: SecretStoreService

    // MARK: - Initialize
    public init(baseURL: URL, secretStoreService: SecretStoreService = SecretStoreServiceImpl()) {
        self.baseURL = baseURL
        self.secretStoreService = secretStoreService
    }

    @discardableResult
    public func signIn(username: String,
                       password: String,
                       callbackQueue: CallbackQueue? = nil,
                       handler: @escaping (Result<Void, TrainingError>) -> Void) -> SessionTask? {
        guard secretStoreService.accessToken == nil && secretStoreService.refreshToken == nil else {
            handler(.failure(.existUser))
            return nil
        }
        let request = TrainingAPI.SignInRequest(baseURL: baseURL, username: username, password: password)
        let task = Session.shared.send(request, callbackQueue: callbackQueue) { [weak self] result in
            switch result {
            case .success(let response):
                self?.secretStoreService.accessToken = response.access
                self?.secretStoreService.refreshToken = response.refresh
                handler(.success(()))
            case .failure(let error):
                let trainingError: TrainingError
                switch APIError(error: error) {
                case .connectionError:
                    trainingError = .connection
                case .requestError:
                    trainingError = .request
                case .nonHTTPURLResponse:
                    trainingError = .nonHTTPURLResponse
                case .unacceptableStatusCode(let statusCode):
                    trainingError = .unacceptableStatusCode(statusCode.rawValue)
                case .unexpectedObject(let object):
                    trainingError = .unexpectedObject(object)
                case .responseError(let error):
                    trainingError = .response(error)
                case .unknownError(let error):
                    trainingError = .unknown(error)
                }
                handler(.failure(trainingError))
            }
        }
        return task
    }

    public func getIDToken(handler: @escaping (Result<String, TrainingError>) -> Void) {
        guard let accessToken = secretStoreService.accessToken else {
            handler(.failure(.noUser))
            return
        }
        handler(.success(accessToken))
    }

    @discardableResult
    public func refresh(callbackQueue: APIKit.CallbackQueue? = nil,
                        handler: @escaping (Result<Void, TrainingError>) -> Void) -> SessionTask? {
        guard let refreshToken = secretStoreService.refreshToken else {
            handler(.failure(.noUser))
            return nil
        }

        let currentAccessToken = secretStoreService.accessToken
        secretStoreService.accessToken = nil

        let request = TrainingAPI.RefreshTokenRequest(baseURL: baseURL, refreshToken: refreshToken)
        let task = Session.shared.send(request, callbackQueue: callbackQueue) { [weak self] result in
            switch result {
            case .success(let response):
                self?.secretStoreService.accessToken = response.access
                guard self?.secretStoreService.accessToken != currentAccessToken else {
                    // 戻しておく
                    self?.secretStoreService.accessToken = currentAccessToken
                    handler(.failure(.failureAccessTokenRefresh))
                    return
                }
                handler(.success(()))
            case .failure(let error):
                let trainingError: TrainingError
                switch APIError(error: error) {
                case .connectionError:
                    trainingError = .connection
                case .requestError:
                    trainingError = .request
                case .nonHTTPURLResponse:
                    trainingError = .nonHTTPURLResponse
                case .unacceptableStatusCode(let statusCode):
                    trainingError = .unacceptableStatusCode(statusCode.rawValue)
                case .unexpectedObject(let object):
                    trainingError = .unexpectedObject(object)
                case .responseError(let error):
                    trainingError = .response(error)
                case .unknownError(let error):
                    trainingError = .unknown(error)
                }
                handler(.failure(trainingError))
            }
        }
        return task
    }

    public func signOut() {
        secretStoreService.accessToken = nil
        secretStoreService.refreshToken = nil
    }
}
