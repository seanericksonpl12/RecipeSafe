//
//  ShareViewController.swift
//  Shared
//
//  Created by Sean Erickson on 7/14/23.
//

import UIKit
import Social
import CoreServices
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let extensionObj = extensionContext?.inputItems.first as? NSExtensionItem, let itemProvider = extensionObj.attachments?.first else {
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }

        if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            handleURL(provider: itemProvider)
        } else {
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }
    
    private func handleURL(provider: NSItemProvider) {
        
        provider.loadItem(forTypeIdentifier: UTType.url.identifier) { (item, error) in
            if let error = error { print(error.localizedDescription) }
            
            if let url = item as? NSURL {
                guard let itemComponents = URLComponents(url: url as URL, resolvingAgainstBaseURL: true) else {
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
                self.extensionContext?.completeRequest(returningItems: nil) { _ in
                    _ = self.openURL(finalURL)
                }
            }
        }
    }
    
    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        
        while responder != nil {
            if let app = responder as? UIApplication, app.responds(to: #selector(openURL(_:))) {
                return app.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }

}
