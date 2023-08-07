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
            
            if let url = item as? NSURL, let urlString = url.absoluteString, let finalURL = URL(string: "RecipeSafe://".appending(urlString)) {
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
