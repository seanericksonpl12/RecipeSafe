//
//  GridButton.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/11/23.
//

import SwiftUI

struct GridButton: View {
    
    @Binding var isEditing: Bool
    var geoProxy: GeometryProxy
    var group: GroupItem
    var deleteAction: () -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .stroke(Color.secondary, lineWidth: 4)
            .background(.background)
            .frame(width: (geoProxy.size.width / 3), height: (geoProxy.size.width / 3))
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
