//
//  ColorSet.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/19/23.
//

import Foundation
import SwiftUI

struct ColorSet {
    static let tan = Color("Tan")
    static let red = Color("Red")
    static let yellow = Color("Yellow")
    static let blue = Color("Blue")
    static let aqua = Color("Aqua")
    static let pink = Color("Pink")
    
    static func random() -> Color {
        let randInt = Int.random(in: 1..<7)
        return ColorSet.color(randInt)
    }
    
    static func color(_ num: Int?) -> Color {
        switch num {
        case 1:
            return ColorSet.tan
        case 2:
            return ColorSet.red
        case 3:
            return ColorSet.yellow
        case 4:
            return ColorSet.blue
        case 5:
            return ColorSet.aqua
        case 6:
            return ColorSet.pink
        default:
            return ColorSet.random()
        }
    }
}
