//
//  AccessToken.swift
//  
//
//  Created by Yuya Oka on 2022/01/12.
//

import Foundation

struct AccessToken: Decodable {
    // MARK: - Properties
    let access: String
    let refresh: String
}
