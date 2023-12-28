//
//  SecretStoreService.swift
//  
//
//  Created by Yuya Oka on 2022/01/12.
//

import Foundation
import KeychainAccess

public protocol SecretStoreService: AnyObject {
    func getAccessToken() async -> String?
    func getRefreshToken() async -> String?
    func setAccessToken(_ accessToken: String?) async
    func setRefreshToken(_ refreshToken: String?) async
}

public final actor SecretStoreServiceImpl: SecretStoreService {
    // MARK: - Properties
    private let keychain: Keychain
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()

    // MARK: - Key
    enum Key: String {
        case accessToken = "key_access_token"
        case refreshToken = "key_refresh_token"
    }

    // MARK: - Initialize
    public init() {
        self.keychain = .init(service: "moe.nnsnodnb.training-auth-sdk.secret")
            .accessibility(.whenUnlockedThisDeviceOnly)
    }

    public func getAccessToken() -> String? {
        object(forKey: .accessToken)
    }

    public func getRefreshToken() -> String? {
        object(forKey: .refreshToken)
    }

    public func setAccessToken(_ accessToken: String?) {
        set(accessToken, forKey: .accessToken)
    }

    public func setRefreshToken(_ refreshToken: String?) {
        set(refreshToken, forKey: .refreshToken)
    }
}

// MARK: - Write
private extension SecretStoreServiceImpl {
    func set<E: Encodable>(_ object: E?, forKey key: Key) {
        guard let object = object, let data = try? jsonEncoder.encode(object) else {
            keychain[key.rawValue] = nil
            return
        }
        keychain[data: key.rawValue] = data
    }
}

// MARK: - Read
private extension SecretStoreServiceImpl {
    func object<D: Decodable>(forKey key: Key) -> D? {
        guard let data = keychain[data: key.rawValue] else { return nil }
        return try? jsonDecoder.decode(D.self, from: data)
    }
}
