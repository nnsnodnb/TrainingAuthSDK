//
//  SecretStoreService.swift
//  
//
//  Created by Yuya Oka on 2022/01/12.
//

import Foundation
import KeychainAccess

public protocol SecretStoreService: AnyObject {
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
}

public final class SecretStoreServiceImpl: SecretStoreService {
    // MARK: - Properties
    public var accessToken: String? {
        get {
            return object(forKey: .accessToken)
        }
        set {
            set(newValue, forKey: .accessToken)
        }
    }
    public var refreshToken: String? {
        get {
            return object(forKey: .refreshToken)
        }
        set {
            set(newValue, forKey: .refreshToken)
        }
    }

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
