//
//  ImageData.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/7/23.
//

import Foundation

enum ImageData: Equatable {
    
    case downloaded(URL)
    case selected(Data)
    case none
    
    static func ==(lhs: ImageData, rhs: ImageData) -> Bool {
        switch (lhs, rhs) {
        case (.selected(let a), .selected(let b)):
            return a == b
        case (.selected(_), .downloaded(_)):
            return false
        case (.selected(_), .none):
            return false
        case (.downloaded(let a), .downloaded(let b)):
            return a == b
        case (.downloaded(_), .selected(_)):
            return false
        case (.downloaded(_), .none):
            return false
        case (.none, .none):
            return true
        case (.none, .selected(_)):
            return false
        case (.none, .downloaded(_)):
            return false
        }
    }
}
