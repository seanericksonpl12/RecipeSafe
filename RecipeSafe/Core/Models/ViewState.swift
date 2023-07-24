//
//  ViewState.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/24/23.
//

import Foundation

enum ViewState: Hashable {
    case loading
    case failedToLoad
    case successfullyLoaded
    case started
}
