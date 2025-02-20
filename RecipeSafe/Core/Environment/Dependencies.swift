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

extension EnvironmentValues {
    @Entry var services = ServiceValues(
        network: .defaultValue,
        recipeData: .defaultValue,
        groupData: .defaultValue,
        shoppingListData: .defaultValue
    )
    
    @Entry var toolbarActions = ToolbarActions(
        save: {},
        delete: {},
        cancel: {},
        option1: {},
        option2: {}
    )
}
