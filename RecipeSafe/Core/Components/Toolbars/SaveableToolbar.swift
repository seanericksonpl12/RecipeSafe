//
//  SaveableToolbar.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/13/24.
//

import Foundation
import SwiftUI

struct SaveableToolbar: ToolbarContent {
    
    var save: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem {
            Button {
                save()
            } label: {
                Image(systemName: "square.and.arrow.down")
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
            }
        }
    }
}
