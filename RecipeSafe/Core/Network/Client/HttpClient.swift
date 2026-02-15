//
//  HttpClient.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/20/25.
//

import Foundation

protocol NetworkClient: Sendable {
  
  var session: URLSession { get }
  
  func request<T: Decodable>(url: String) async throws -> T
  
  func request<T: Decodable>(
    url: String,
    method: HttpMethod?,
    body: HttpBody?,
    queryItems: [String: String]?,
    headers: [String: String]?
  ) async throws -> T
  
  func request(url: String) async throws -> Data
  
  func request(
    url: String,
    method: HttpMethod?,
    body: HttpBody?,
    queryItems: [String: String]?,
    headers: [String: String]?
  ) async throws -> Data
}

struct HttpClient: NetworkClient {
  
  let session: URLSession
  
  private let decoder = JSONDecoder()
  
  init(session: URLSession = .shared) {
    self.session = session
  }
  
  func request<T: Decodable>(url: String) async throws -> T {
    try await request(url: url, method: .get, body: nil, queryItems: nil, headers: nil)
  }
  
  func request<T: Decodable>(
    url: String,
    method: HttpMethod?,
    body: HttpBody?,
    queryItems: [String: String]?,
    headers: [String : String]?
  ) async throws -> T {
    let request = try buildRequest(url: url, method: method, body: body, queryItems: queryItems, headers: headers)
    Logger.logRequest(request)
    let (data, response) = try await session.data(for: request)
    Logger.logResponse(response, data: data)
    try validateResponse(response)
    return try decoder.decode(T.self, from: data)
  }
  
  func request(url: String) async throws -> Data {
    try await request(url: url, method: .get, body: nil, queryItems: nil, headers: nil)
  }
  
  func request(
    url: String,
    method: HttpMethod?,
    body: HttpBody?,
    queryItems: [String: String]?,
    headers: [String : String]?
  ) async throws -> Data {
    let request = try buildRequest(url: url, method: method, body: body, queryItems: queryItems, headers: headers)
    Logger.logRequest(request)
    let (data, response) = try await session.data(for: request)
    Logger.logResponse(response, data: data)
    try validateResponse(response)
    return data
  }
  
  private func buildRequest(
    url: String,
    method: HttpMethod?,
    body: HttpBody?,
    queryItems: [String: String]?,
    headers: [String: String]?
  ) throws -> URLRequest {
    guard var components = URLComponents(string: url) else {
      throw NetworkError.invalidURL("Bad URL: \(url)")
    }
    
    if components.queryItems == nil {
      components.queryItems = []
    }
    
    queryItems?.forEach {
      let urlQuery = URLQueryItem(name: $0.key, value: $0.value)
      components.queryItems!.append(urlQuery)
    }
    
    
    guard let url = components.url else {
      throw NetworkError.invalidURL("Component has no URL")
    }
    
    var urlRequest = URLRequest(url: url)
    
    urlRequest.httpMethod = method?.rawValue ?? HttpMethod.get.rawValue
    
    if let headers {
      for (key, value) in headers {
        if urlRequest.value(forHTTPHeaderField: key) == nil {
          urlRequest.addValue(value, forHTTPHeaderField: key)
        } else {
          urlRequest.setValue(value, forHTTPHeaderField: key)
        }
      }
    }
    
    urlRequest.httpBody = body?.data
    
    return urlRequest
  }
  
  private func validateResponse(_ response: URLResponse) throws {
    guard let urlResponse = response as? HTTPURLResponse else {
      throw NetworkError.badResponse("Invalid http response")
    }
    
    guard urlResponse.statusCode >= 200 && urlResponse.statusCode < 400 else {
      throw NetworkError.failedWithStatus(urlResponse.statusCode)
    }
  }
}

struct MockHttpClient: NetworkClient {
  var session: URLSession
  func request<T>(url: String) async throws -> T where T : Decodable { throw URLError(.cancelled) }
  func request<T>(url: String, method: HttpMethod?, body: HttpBody?, queryItems: [String : String]?, headers: [String : String]?) async throws -> T where T : Decodable { throw URLError(.cancelled) }
  func request(url: String) async throws -> Data { throw URLError(.cancelled) }
  func request(url: String, method: HttpMethod?, body: HttpBody?, queryItems: [String : String]?, headers: [String : String]?) async throws -> Data { throw URLError(.cancelled) }
}
