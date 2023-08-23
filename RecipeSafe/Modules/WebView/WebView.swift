//
//  WebView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/22/23.
//

import SwiftUI
import WebKit

struct WebView: View {
    
    @StateObject var webDelegate: WebKitDelegate = WebKitDelegate()
    @State var searchText: String = ""
    
    var body: some View {
            VStack {
                HStack {
                    Button {
                        webDelegate.goBack()
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                    .padding()
                    Spacer()
                    
                    Spacer()
                    Button {
                        webDelegate.openURL()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .padding()
                }
                .background(Color.secondary)
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
