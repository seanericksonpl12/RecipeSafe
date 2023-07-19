//
//  ErrorTypes.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/17/23.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL(String), noResponse(String)
}
