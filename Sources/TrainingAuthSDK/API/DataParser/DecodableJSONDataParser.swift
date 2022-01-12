//
//  DecodableJSONDataParser.swift
//  
//
//  Created by Yuya Oka on 2022/01/12.
//

import APIKit
import Foundation

final class DecodableJSONDataParser: DataParser {
    // MARK: - Properties
    let contentType: String? = "application/json"

    func parse(data: Data) throws -> Any {
        return data
    }
}
