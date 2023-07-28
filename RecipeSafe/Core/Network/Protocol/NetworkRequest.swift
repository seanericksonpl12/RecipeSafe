//
//  NetworkRequest.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/26/23.
//

import Foundation

protocol NetworkRequest {
    
    associatedtype Response
    
    var url: String { get }
    var method: HTTPMethod? { get }
    var header: [String:String] { get }
    var queryItems: [String:String] { get }
    var body: Data? { get }
    
    func decode(_ data: Data) throws -> Response
}

extension NetworkRequest where Response: Decodable {
    func decode(_ data: Data) throws -> Response {
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

extension NetworkRequest {
    var header: [String:String] { [:] }
    var queryItems: [String:String] { [:] }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
