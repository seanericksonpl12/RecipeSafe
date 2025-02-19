//
//  NetworkProtocol.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/26/23.
//

import Foundation
import CoreData

protocol Network {
    
    var session: URLSession { get }
    
    func executeRequest<Request: NetworkRequest>(request: Request,
                                                 retries: Int) async -> Result<Request.Response, Error>
    
    func executeStream<Request: NetworkRequest>(request: Request) async throws -> AsyncCompactMapSequence<AsyncLineSequence<URLSession.AsyncBytes>, Request.Response>
    
    func getHTML(request: URLRequest,
                 retries: Int) async -> Result<String, Error>
}

// MARK: - Default Functions
extension Network {
    
    func executeRequest<Request: NetworkRequest>(request: Request,
                                                 retries: Int) async -> Result<Request.Response, Error> {
        
        guard var components = URLComponents(string: request.url) else {
            return .failure(NetworkError.invalidURL("Bad URL: \(request.url)"))
        }
        
        if components.queryItems == nil {
            components.queryItems = []
        }
        
        request.queryItems.forEach {
            let urlQuery = URLQueryItem(name: $0.key, value: $0.value)
            components.queryItems!.append(urlQuery)
        }
        
        
        guard let url = components.url else {
            return .failure(NetworkError.invalidURL("Component has no URL"))
        }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = request.method?.rawValue
        urlRequest.allHTTPHeaderFields = request.header
        urlRequest.httpBody = request.body
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200, httpResponse.statusCode <= 400 else {
                return .failure(NetworkError.badResponse(response.debugDescription))
            }
            let object = try request.decode(data)
            return .success(object)
        } catch {
            return .failure(error)
        }
    }
    
    func executeStream<Request: NetworkRequest>(request: Request) async throws -> AsyncCompactMapSequence<AsyncLineSequence<URLSession.AsyncBytes>, Request.Response> {
        
        guard var components = URLComponents(string: request.url) else {
            throw NetworkError.invalidURL("Bad URL: \(request.url)")
        }
        
        if components.queryItems == nil {
            components.queryItems = []
        }
        
        request.queryItems.forEach {
            let urlQuery = URLQueryItem(name: $0.key, value: $0.value)
            components.queryItems!.append(urlQuery)
        }
        
        guard let url = components.url else {
            throw NetworkError.invalidURL("Component has no URL")
        }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = request.method?.rawValue
        urlRequest.allHTTPHeaderFields = request.header
        urlRequest.httpBody = request.body
        
        let (bytes, response) = try await self.session.bytes(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200, httpResponse.statusCode <= 400 else {
            throw NetworkError.badResponse(response.debugDescription)
        }
        
        return bytes.lines.compactMap { try? request.decode(Data($0.utf8)) }
    }
    
    func getHTML(request: URLRequest, retries: Int) async -> Result<String, Error> {
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200, httpResponse.statusCode <= 400 else {
                return .failure(NetworkError.badResponse(response.debugDescription))
            }
            guard let string = String(data: data, encoding: .utf8) else {
                return .failure(NetworkError.failedToDecodeJSON("Failed to decode data"))
            }
            return .success(string)
        } catch {
            return .failure(error)
        }
    }
}

struct NetworkService: Sendable, Service {
    let fetchData: @Sendable () async throws -> Void
    let fetchAuthData: @Sendable () async throws -> Void
    let fetchAuthStream: @Sendable () async throws -> Void
}

extension NetworkService {
    static var defaultValue: Self { .mock }
    
    static func live(viewContext: NSManagedObjectContext) -> Self {
        .init(
            fetchData: {
                
            },
            fetchAuthData: {
                
            },
            fetchAuthStream: {
                
            }
        )
    }
    
    static var mock: Self {
        .init(
            fetchData: {
                
            },
            fetchAuthData: {
                
            },
            fetchAuthStream: {
                
            }
        )
    }
}

struct NetworkClient {
    
}
