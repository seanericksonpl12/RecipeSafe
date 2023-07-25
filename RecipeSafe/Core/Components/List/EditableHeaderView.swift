//
//  EditableHeaderView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/25/23.
//

import SwiftUI

struct EditableHeaderView: View {
    
    @Binding var headerText: String
    @Binding var isEditing: Bool
    
    var saveAction: () -> Void
    var cancelAction: () -> Void
    var deleteAction: () -> Void
    
    var imgUrl: URL?
    
    var body: some View {
        HStack {
            Spacer()
            AsyncImage(url: imgUrl) { img in
                img.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 70, maxHeight: 70)
                    .clipShape(Circle())
            } placeholder: {
                Image(systemName: "circle.dotted")
                    .frame(maxWidth: 70, maxHeight: 70)
            }
            TextField("", text: $headerText, axis: .vertical)
                .font(.title)
                .fontWeight(.heavy)
                .padding()
                .disabled(!isEditing)
            Spacer()
        }
        .editableToolbar(isEditing: $isEditing,
                         saveAction: saveAction,
                         cancelAction: cancelAction,
                         deleteAction: deleteAction)
    }
}
