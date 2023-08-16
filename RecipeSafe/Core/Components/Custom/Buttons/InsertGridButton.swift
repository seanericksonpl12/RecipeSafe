//
//  GroupGrid.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/11/23.
//

import SwiftUI

struct InsertGridButton: View {
    
    // MARK: - Properties
    var insertAction: () -> Void
    var width: CGFloat
    var height: CGFloat
    
    // MARK: - Body
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .stroke(.secondary, lineWidth: 4)
            .frame(width: width, height: height)
            .overlay {
                Image(systemName: "plus.circle")
                    .resizable()
                    .foregroundColor(.secondary)
                    .padding()
            }
            .padding()
            .onTapGesture {
                insertAction()
            }
    }
}
