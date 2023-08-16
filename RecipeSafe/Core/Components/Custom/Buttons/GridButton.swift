//
//  GridButton.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/11/23.
//

import SwiftUI

struct GridButton: View {
    
    // MARK: - Wrapped
    @Binding var isEditing: Bool
    
    // MARK: - Properties
    var geoProxy: GeometryProxy
    var group: GroupItem
    var deleteAction: () -> Void
    
    // MARK: - Body
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .stroke(Color.secondary, lineWidth: 4)
            .background(.background)
            .frame(width: (geoProxy.size.width / 2.75), height: (geoProxy.size.width / 2.75))
            .overlay {
                if isEditing {
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                deleteAction()
                            } label: {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.red)
                            }
                            .padding()
                        }
                        Spacer()
                    }
                }
                Text(group.title ?? "" )
                    .foregroundColor(.secondary)
            }
            .padding()
    }
}
