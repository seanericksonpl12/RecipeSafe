//
//  GroupGrid.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/11/23.
//

import SwiftUI

struct InsertGridButton: View {
    
    var insertAction: () -> Void
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .stroke(.blue, lineWidth: 4)
            .frame(width: width, height: height)
            .overlay {
                Image(systemName: "plus.circle")
                    .resizable()
                    .foregroundColor(.blue)
                    .padding()
            }
            .padding()
            .onTapGesture {
                insertAction()
            }
    }
}
