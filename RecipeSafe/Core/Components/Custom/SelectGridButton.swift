//
//  SelectGridButton.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/14/23.
//

import SwiftUI

struct SelectGridButton: View {
    
    @State private var selected: Bool = false
    var geoProxy: GeometryProxy
    var group: GroupItem
    var selectAction: () -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .stroke(Color.secondary, lineWidth: 4)
            .background(.background)
            .frame(width: (geoProxy.size.width / 2.75), height: (geoProxy.size.width / 2.75))
            .overlay {
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                selectAction()
                                self.selected.toggle()
                            } label: {
                                Image(systemName: self.selected ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(.primary)
                            }
                            .padding()
                        }
                        Spacer()
                    }
                Text(group.title ?? "" )
                    .foregroundColor(.secondary)
            }
            .padding()
    }
}
