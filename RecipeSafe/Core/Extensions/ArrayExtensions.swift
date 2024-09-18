//
//  ArrayExtensions.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/16/24.
//

import Foundation

extension Array {
    func safeValue(at index: Int) -> Element? {
        if self.count > index {
            return self[index]
        } else {
            return nil
        }
    }
    
    @discardableResult
    mutating func safeSet(at index: Int, _ value: Element) -> Bool {
        if self.count > index {
            self[index] = value
            return true
        } else {
            return false
        }
    }
}

extension Array where Element: Primitive {
    struct IdentifiablePrimitive: Identifiable {
        fileprivate init(_ value: Element) { self.id = UUID(); self.value = value }
        var id: UUID
        var value: Element
    }
    
    func toIdentifiable() -> [IdentifiablePrimitive] {
        print(self)
        if self.isEmpty { return [] }
        return self.map { IdentifiablePrimitive($0) }
    }
}
