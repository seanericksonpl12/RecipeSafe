//
//  NetworkProtocol.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/26/23.
//

import Foundation
import Combine

protocol NetworkProtocol {
    
    var session: URLSession { get }
    
    func executeRequest<Request: NetworkRequest>(request: Request,
                                                 retries: Int) -> AnyPublisher<Request.Response, Error>
    
    func getHTML(request: URLRequest,
                 retries: Int) -> AnyPublisher<String, Error>
}

extension NetworkProtocol {
    
    func executeRequest<Request: NetworkRequest>(request: Request,
                                    retries: Int) -> AnyPublisher<Request.Response, Error> {
        
        guard var components = URLComponents(string: request.url) else {
            return Fail(error: NetworkError.invalidURL("Bad URL: \(request.url)")).eraseToAnyPublisher()
        }
        
        if components.queryItems == nil {
            components.queryItems = []
        }
        
        request.queryItems.forEach {
            let urlQuery = URLQueryItem(name: $0.key, value: $0.value)
            components.queryItems!.append(urlQuery)
        }
        
        
        guard let url = components.url else {
            return Fail(error: NetworkError.invalidURL("Component has no URL")).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = request.method?.rawValue
        urlRequest.allHTTPHeaderFields = request.header
        urlRequest.httpBody = request.body
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { reply in
                guard let response = reply.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw NetworkError.badResponse("Bad response: \(reply.response.debugDescription)")
                }
                return try request.decode(reply.data)
            }
            .receive(on: DispatchQueue.main)
            .retry(retries)
            .eraseToAnyPublisher()
    }
    
    func getHTML(request: URLRequest, retries: Int) -> AnyPublisher<String, Error> {
        session.dataTaskPublisher(for: request)
            .tryMap { reply in
                guard let response = reply.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw NetworkError.badResponse("Bad response: \(reply.response.debugDescription)")
                }
                guard let string = String(data: reply.data, encoding: .utf8) else {
                    throw NetworkError.failedToDecodeJSON("Failed to decode data")
                }
                return string
            }
            .receive(on: DispatchQueue.main)
            .retry(retries)
            .eraseToAnyPublisher()
    }
}


