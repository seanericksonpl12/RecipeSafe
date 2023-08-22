//
//  WebView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/22/23.
//

import SwiftUI
import WebKit

struct WebView: View {
    
    var webDelegate: WebKitDelegate = WebKitDelegate()
    
    var body: some View {
        VStack {
            Text(String(webDelegate.estimatedProgress))
            WebUIView(url: URL(string: "https://www.google.com")!, delegate: webDelegate)
            Text("footer here")
        }
    }
}

fileprivate struct WebUIView: UIViewRepresentable {
    
    var url: URL
    var delegate: WebKitDelegate
    
    func makeUIView(context: Context) -> WKWebView {
        let webKit = delegate
        webKit.navigationDelegate = webKit
        return webKit
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
