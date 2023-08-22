//
//  WebKitManager.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/22/23.
//

import UIKit
import SwiftUI
import WebKit

class WebKitDelegate: WKWebView, WKNavigationDelegate {
    
    var contentRules: WKContentRuleList?
    
    init?(contentRules: WKContentRuleList? = nil) {
        super.init(coder: NSCoder())
        self.contentRules = contentRules
        self.setupContentRules()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        return WKNavigationActionPolicy.allow
    }
    
    func setupContentRules() {
        WKContentRuleListStore
            .default()
            .compileContentRuleList(forIdentifier: "adBlock",
                                    encodedContentRuleList: "Test") { list, error in
                if let error = error {
                    print(error)
                    return
                }
                self.contentRules = list
            }
    }
}
