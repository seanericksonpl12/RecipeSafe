//
//  Logger.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/24/25.
//

//
//  Logger.swift
//  AppAttestationExample
//

import Foundation
import OSLog

class Logger {
    
    enum Category {
        case network, security, `default`
    }
    
    private init() {}
    
    private static let networkLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "App.DefaultSubSystem", category: "Network")
    private static let securityLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "App.DefaultSubSystem", category: "Security")
    private static let defaultLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "App.DefaultSubSystem", category: "Default")
    
    static func log(_ message: String, type: OSLogType = .default, category: Category = .default) {
        if AppEnvironment.shouldMock {
            print(message)
            return
        }
        switch category {
        case .network:
            os_log("%{public}@", log: networkLog, type: type, message)
        case .security:
            os_log("%{public}@", log: securityLog, type: type, message)
        case .default:
            os_log("%{public}@", log: defaultLog, type: type, message)
        }
    }
    
    static func logResponse(_ response: URLResponse, data: Data?) {
        guard let url = response.url else { return }
        let httpResponse = response as? HTTPURLResponse
        let statusCode = httpResponse?.statusCode
        
        var message = "← Received: \(statusCode ?? 0) from \(url.absoluteString)\n"
        message.append("Headers:\n")
        for header in httpResponse?.allHeaderFields ?? [:] {
            message.append("  \(header.key): \(header.value)\n")
        }
        if let data, let body = String(data: data, encoding: .utf8) {
            message.append("Body:\n")
            message.append("  \(body)")
        }
        
        os_log("%{public}@", log: networkLog, type: .default, message)
    }
    
    static func logRequest(_ request: URLRequest) {
        guard let url = request.url else { return }
        print("logging request")
        
        var baseCommand = "→ Requesting: curl \"\(url.absoluteString)\""
        if request.httpMethod == "HEAD" {
            baseCommand += " --head"
        }
        
        var commandLines = [baseCommand]
        
        if let method = request.httpMethod, method != "GET", method != "HEAD" {
            commandLines.append("-X \(method)")
        }
        
        if let headers = request.allHTTPHeaderFields {
            for (key, value) in headers where key != "Cookie" {
                commandLines.append("-H '\(key): \(value)'")
            }
        }
        
        if let data = request.httpBody, let body = String(data: data, encoding: .utf8) {
            commandLines.append("-d '\(body)'")
        }
        
        let command = commandLines.joined(separator: " \\\n\t")
        os_log("%{public}@", log: networkLog, type: .default, command)
    }
}
