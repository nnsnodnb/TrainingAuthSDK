//
//  Auth.swift
//  
//
//  Created by Yuya Oka on 2022/01/12.
//

import APIKit
import Foundation
import JWTDecode

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

    public func signIn(username: String, password: String, callbackQueue: CallbackQueue? = nil) async throws {
        guard secretStoreService.accessToken == nil && secretStoreService.refreshToken == nil else {
            throw TrainingError.existUser
        }
        let request = TrainingAPI.SignInRequest(baseURL: baseURL, username: username, password: password)
        do {
            let response = try await Session.shared.response(for: request, callbackQueue: callbackQueue)
            secretStoreService.accessToken = response.access
            secretStoreService.refreshToken = response.refresh
        } catch {
            let trainingError: TrainingError
            switch APIError(error: error) {
            case .connectionError:
                trainingError = .connection
            case .requestError:
                trainingError = .request
            case .nonHTTPURLResponse:
                trainingError = .nonHTTPURLResponse
            case let .unacceptableStatusCode(statusCode):
                trainingError = .unacceptableStatusCode(statusCode.rawValue)
            case let .unexpectedObject(object):
                trainingError = .unexpectedObject(object)
            case let .responseError(error):
                trainingError = .response(error)
            case let .unknownError(error):
                trainingError = .unknown(error)
            }
            throw trainingError
        }
    }

    @discardableResult
    public func signIn(
        username: String,
        password: String,
        callbackQueue: CallbackQueue? = nil,
        handler: @escaping (Result<Void, TrainingError>) -> Void
    ) -> SessionTask? {
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
            case let .failure(error):
                let trainingError: TrainingError
                switch APIError(error: error) {
                case .connectionError:
                    trainingError = .connection
                case .requestError:
                    trainingError = .request
                case .nonHTTPURLResponse:
                    trainingError = .nonHTTPURLResponse
                case let .unacceptableStatusCode(statusCode):
                    trainingError = .unacceptableStatusCode(statusCode.rawValue)
                case let .unexpectedObject(object):
                    trainingError = .unexpectedObject(object)
                case let .responseError(error):
                    trainingError = .response(error)
                case let .unknownError(error):
                    trainingError = .unknown(error)
                }
                handler(.failure(trainingError))
            }
        }
        return task
    }

    public func getIDToken(forceRefresh: Bool = false, callbackQueue: APIKit.CallbackQueue? = nil) async throws -> String {
        guard let accessToken = secretStoreService.accessToken,
              let jwtToken = try? decode(jwt: accessToken) else {
            throw TrainingError.noUser
        }
        guard forceRefresh || jwtToken.expired else {
            return accessToken
        }

        return try await refresh(callbackQueue: callbackQueue)
    }

    public func getIDToken(
        forceRefresh: Bool = false,
        callbackQueue: APIKit.CallbackQueue? = nil,
        handler: @escaping (Result<String, TrainingError>) -> Void
    ) {
        guard let accessToken = secretStoreService.accessToken,
              let jwtToken = try? decode(jwt: accessToken) else {
            handler(.failure(.noUser))
            return
        }
        guard forceRefresh || jwtToken.expired else {
            handler(.success(accessToken))
            return
        }
        refresh(callbackQueue: callbackQueue) { result in
            switch result {
            case let .success(accessToken):
                handler(.success(accessToken))
            case let .failure(error):
                handler(.failure(error))
            }
        }
    }

    public func refresh(callbackQueue: APIKit.CallbackQueue? = nil) async throws -> String {
        guard let refreshToken = secretStoreService.refreshToken else {
            throw TrainingError.noUser
        }

        let currentAccessToken = secretStoreService.accessToken
        secretStoreService.accessToken = nil

        let request = TrainingAPI.RefreshTokenRequest(baseURL: baseURL, refreshToken: refreshToken)
        do {
            let response = try await Session.shared.response(for: request, callbackQueue: callbackQueue)
            secretStoreService.accessToken = response.access
            guard secretStoreService.accessToken != currentAccessToken else {
                // 戻しておく
                secretStoreService.accessToken = currentAccessToken
                throw TrainingError.failureAccessTokenRefresh
            }
            return response.access
        } catch {
            let trainingError: TrainingError
            switch APIError(error: error) {
            case .connectionError:
                trainingError = .connection
            case .requestError:
                trainingError = .request
            case .nonHTTPURLResponse:
                trainingError = .nonHTTPURLResponse
            case let .unacceptableStatusCode(statusCode):
                trainingError = .unacceptableStatusCode(statusCode.rawValue)
            case let .unexpectedObject(object):
                trainingError = .unexpectedObject(object)
            case let .responseError(error):
                trainingError = .response(error)
            case let .unknownError(error):
                trainingError = .unknown(error)
            }
            throw trainingError
        }
    }

    @discardableResult
    public func refresh(
        callbackQueue: APIKit.CallbackQueue? = nil,
        handler: @escaping (Result<String, TrainingError>) -> Void
    ) -> SessionTask? {
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
                handler(.success(response.access))
            case let .failure(error):
                let trainingError: TrainingError
                switch APIError(error: error) {
                case .connectionError:
                    trainingError = .connection
                case .requestError:
                    trainingError = .request
                case .nonHTTPURLResponse:
                    trainingError = .nonHTTPURLResponse
                case let .unacceptableStatusCode(statusCode):
                    trainingError = .unacceptableStatusCode(statusCode.rawValue)
                case let .unexpectedObject(object):
                    trainingError = .unexpectedObject(object)
                case let .responseError(error):
                    trainingError = .response(error)
                case let .unknownError(error):
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
