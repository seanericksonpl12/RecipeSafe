//
//  StringExtensions.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/24/23.
//

import Foundation

// MARK: - Formatting
extension String {
    
    func htmlFormatted() -> String {
        guard let data = self.data(using: .utf8) else { return self }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: data,
                                                             options: options,
                                                             documentAttributes: nil) else { return self }
        return String(attributedString.string)
    }
}

// MARK: - Localized Value
extension String {
    var localized: String { String(localized: LocalizationValue(stringLiteral: self)) }
}
