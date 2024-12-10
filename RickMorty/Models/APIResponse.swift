//
//  APIResponse.swift
//  RickMorty
//
//  Created by Adam Kopeć on 08/06/2024.
//

import Foundation

struct APIResponse<T: Codable>: Codable {
    let info: APIResponseInfo
    let results: [T]
}

struct APIResponseInfo: Codable {
    let count: Int
    let pages: Int
    let next: URL?
    let prev: URL?
}

struct APIErrorResponse: Codable {
    let error: String
}

struct APIError: Error {
    let message: String
}
