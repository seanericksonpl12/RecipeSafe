//
//  JSONParser.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/2/23.
//

import Foundation


protocol JSONParser {
    var data: Data { get }
    
    func parse<T>() throws -> T
}
