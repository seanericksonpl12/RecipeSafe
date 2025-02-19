//
//  Dependencies.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/25/24.
//

import Foundation
import SwiftUI
import Injector
import CoreData

extension Dependencies {
    var appConfig: AppConfig { resolve() }
}


