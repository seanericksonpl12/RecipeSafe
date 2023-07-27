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
    
    func execute<T>(request: URLRequest,
                    decodeType: T.Type,
                    retries: Int) -> AnyPublisher<T, Error> where T: Decodable
    
    func execute<T>(request: URLRequest,
                    customDecodingStrategy: @escaping (Data) throws -> T,
                    retries: Int) -> AnyPublisher<T, Error>
    
    func executeRequest<Request, T>(request: Request,
                                    decodeType: T.Type,
                                    retries: Int) -> AnyPublisher<T, Error> where Request: NetworkRequest, T: Decodable
    
    func getHTML(request: URLRequest,
                 retries: Int) -> AnyPublisher<String, Error>
}

extension NetworkProtocol {
    
    func execute<T>(request: URLRequest,
                    decodeType: T.Type,
                    retries: Int) -> AnyPublisher<T, Error> where T: Decodable {
        session.dataTaskPublisher(for: request)
            .tryMap { reply in
                guard let response = reply.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return reply.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .retry(retries)
            .eraseToAnyPublisher()
    }
    
    func execute<T>(request: URLRequest,
                    customDecodingStrategy: @escaping (Data) throws -> T,
                    retries: Int) -> AnyPublisher<T, Error> {
        session.dataTaskPublisher(for: request)
            .tryMap { reply in
                guard let response = reply.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return try customDecodingStrategy(reply.data)
            }
            .receive(on: DispatchQueue.main)
            .retry(retries)
            .eraseToAnyPublisher()
        
    }
    
    func executeRequest<Request, T>(request: Request,
                                    decodeType: T.Type,
                                    retries: Int) -> AnyPublisher<T, Error> where Request: NetworkRequest, T: Decodable {
        
        guard var components = URLComponents(string: request.url) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        if components.queryItems == nil {
            components.queryItems = []
        }
        
        request.queryItems.forEach {
            let urlQuery = URLQueryItem(name: $0.key, value: $0.value)
            components.queryItems!.append(urlQuery)
        }
        
        
        guard let url = components.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.header
        urlRequest.httpBody = request.body
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { reply in
                guard let response = reply.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return reply.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .retry(retries)
            .eraseToAnyPublisher()
    }
    
    func getHTML(request: URLRequest, retries: Int) -> AnyPublisher<String, Error> {
        session.dataTaskPublisher(for: request)
            .tryMap { reply in
                guard let response = reply.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                guard let string = String(data: reply.data, encoding: .utf8) else {
                    throw URLError(.cannotDecodeRawData)
                }
                return string
            }
            .receive(on: DispatchQueue.main)
            .retry(retries)
            .eraseToAnyPublisher()
    }
}


