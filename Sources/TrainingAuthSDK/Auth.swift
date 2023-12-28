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
    private let baseURL: URL
    private let secretStoreService: SecretStoreService

    // MARK: - Initialize
    public init(baseURL: URL, secretStoreService: SecretStoreService = SecretStoreServiceImpl()) {
        self.baseURL = baseURL
        self.secretStoreService = secretStoreService
    }

    public func signIn(username: String, password: String, callbackQueue: CallbackQueue? = nil) async throws {
        async let accessToken = secretStoreService.getAccessToken()
        async let refreshToken = secretStoreService.getRefreshToken()
        guard await accessToken == nil, await refreshToken == nil else {
            throw TrainingError.existUser
        }
        let request = TrainingAPI.SignInRequest(baseURL: baseURL, username: username, password: password)
        do {
            let response = try await Session.shared.response(for: request, callbackQueue: callbackQueue)
            await secretStoreService.setAccessToken(response.access)
            await secretStoreService.setRefreshToken(response.refresh)
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

    public func signIn(
        username: String,
        password: String,
        callbackQueue: CallbackQueue? = nil,
        handler: @escaping (Result<Void, TrainingError>) -> Void
    ) {
        Task {
            do {
                try await signIn(username: username, password: password, callbackQueue: callbackQueue)
                handler(.success(()))
            } catch {
                handler(.failure(error as! TrainingError))
            }
        }
    }

    public func getIDToken(forceRefresh: Bool = false, callbackQueue: CallbackQueue? = nil) async throws -> String {
        guard let accessToken = await secretStoreService.getAccessToken(),
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
        callbackQueue: CallbackQueue? = nil,
        handler: @escaping (Result<String, TrainingError>) -> Void
    ) {
        Task {
            do {
                let accessToken = try await getIDToken(forceRefresh: forceRefresh, callbackQueue: callbackQueue)
                handler(.success(accessToken))
            } catch {
                handler(.failure(error as! TrainingError))
            }
        }
    }

    public func refresh(callbackQueue: CallbackQueue? = nil) async throws -> String {
        guard let refreshToken = await secretStoreService.getRefreshToken() else {
            throw TrainingError.noUser
        }

        let currentAccessToken = await secretStoreService.getAccessToken()
        await secretStoreService.setAccessToken(nil)

        let request = TrainingAPI.RefreshTokenRequest(baseURL: baseURL, refreshToken: refreshToken)
        do {
            let response = try await Session.shared.response(for: request, callbackQueue: callbackQueue)
            await secretStoreService.setAccessToken(response.access)
            guard await secretStoreService.getAccessToken() != currentAccessToken else {
                // 戻しておく
                await secretStoreService.setAccessToken(currentAccessToken)
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

    public func refresh(
        callbackQueue: CallbackQueue? = nil,
        handler: @escaping (Result<String, TrainingError>) -> Void
    ) {
        Task {
            do {
                let accessToken = try await refresh(callbackQueue: callbackQueue)
                handler(.success(accessToken))
            } catch {
                handler(.failure(error as! TrainingError))
            }
        }
    }

    public func signOut() async {
        await secretStoreService.setAccessToken(nil)
        await secretStoreService.setRefreshToken(nil)
    }

    public func signOut() {
        Task {
            await signOut()
        }
    }
}
