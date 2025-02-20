//
//  ErrorTypes.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/17/23.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL(String)
    case noResponse(String)
    case badResponse(String)
    case failedToDecodeJSON(String)
    case recipeMissingItem(String)
    case failedWithStatus(Int)
}

enum DataError: LocalizedError {
    case dataReadError(String)
    case jsonReadError(String)
}
