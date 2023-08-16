//
//  StringExtensions.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/24/23.
//

import Foundation


// MARK: - Localized Value
extension String {
    var localized: String { String(localized: LocalizationValue(stringLiteral: self)) }
}

// MARK: - HTML Formatting
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

// MARK: - Decimal Converter
extension String {
    func convertingDec() -> String {
        let regex = /\d\.\d{4}\d+/
        if let match = self.firstMatch(of: regex)?.output {
            let matchStr = String(match)
            
            if var dub = Double(matchStr) {
                var x = dub.rounded(.down)
                var (h1, k1, h, k) = (1, 0, Int(x), 1)
                while dub - x > (1.0E-5 * Double(k) * Double(k)) {
                    dub = 1.0/(dub - x)
                    x = dub.rounded(.down)
                    (h1, k1, h, k) = (h, k, h1 + Int(x) * h, k1 + Int(x) * k)
                }
                if h < 10 {
                    return self.replacingOccurrences(of: matchStr, with: "\(h)/\(k)")
                }
            }
            
            if matchStr.count >= 4 {
                let cutMatch = matchStr[matchStr.startIndex..<matchStr.index(matchStr.startIndex, offsetBy: 4)]
                return self.replacingOccurrences(of: matchStr, with: cutMatch)
            }
        }
        return self
    }
}

// MARK: - Recipe Formatted
extension String {
    func recipeFormatted() -> String {
        self
            .htmlFormatted()
            .convertingDec()
    }
}

extension String {
    func timeFormatted() -> String {
        if self.hasPrefix("PT") {
            return self.replacingOccurrences(of: "PT", with: "")
        }
        let regex = /P\dY\dM\dDT/
        if let match = self.prefixMatch(of: regex)?.output {
            let newStr = self.replacingOccurrences(of: String(match), with: "")

            guard let hourIndex = newStr.firstIndex(of: "H") else { return self }
            guard let minuteIndex = newStr.firstIndex(of: "M") else { return self }
            
            let hours = String(newStr[newStr.startIndex..<hourIndex])
            let minutes = String(newStr[newStr.index(after: hourIndex)..<minuteIndex])
            
            if hours == "0" {
                return "\(minutes)M"
            } else {
                return "\(hours)H \(minutes)M"
            }
        }
        return self
    }
}
