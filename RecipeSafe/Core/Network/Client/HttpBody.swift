//
//  HttpBody.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/20/25.
//

import Foundation

enum HttpBody {
    case json([String: Any])
    case raw(Encodable)
    
    var data: Data? {
        switch self {
        case .json(let dictionary):
            try? JSONSerialization.data(withJSONObject: dictionary, options: [])
        case .raw(let encodable):
            try? JSONEncoder().encode(encodable)
        }
    }
}
