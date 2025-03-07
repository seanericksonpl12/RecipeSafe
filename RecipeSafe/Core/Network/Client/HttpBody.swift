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
            print("body dictionary for request: \(dictionary)")
            let data = dictionary.percentEscaped().data(using: .utf8)
            print(String(data: data!, encoding: .utf8))
            return data
        case .raw(let encodable):
            return try? JSONEncoder().encode(encodable)
        }
    }
}

extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
