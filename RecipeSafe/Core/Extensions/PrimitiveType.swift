//
//  PrimitiveType.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/17/24.
//

import Foundation

protocol Primitive {}
extension String: Primitive {}
extension Int: Primitive {}
extension Bool: Primitive {}
extension Float: Primitive {}
extension Double: Primitive {}
