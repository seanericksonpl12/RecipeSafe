//
//  WebKitManager.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/22/23.
//

import UIKit
import SwiftUI
import WebKit

class WebKitDelegate: WKWebView, WKNavigationDelegate, ObservableObject {
    
    @Published var currentUrl: URL?
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        return WKNavigationActionPolicy.allow
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.currentUrl = webView.url
    }
    
    func openURL() {
        if let url = self.currentUrl {
            guard let itemComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return
            }
            if itemComponents.scheme != "https" {
                return
            }
            guard let urlStr = itemComponents.host?.appending(itemComponents.path) else {
                return
            }
            var urlComponents = URLComponents()
            urlComponents.scheme = "RecipeSafe"
            urlComponents.host = "open-recipe"
            urlComponents.queryItems = [URLQueryItem(name: "url", value: urlStr)]
            guard let finalURL = urlComponents.url else {
                return
            }
            
            UIApplication
                .shared
                .open(finalURL)
        }
    }
}
