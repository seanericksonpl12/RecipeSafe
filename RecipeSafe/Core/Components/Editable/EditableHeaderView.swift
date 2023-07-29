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
    var siteUrl: URL?
    
    var body: some View {
        HStack {
            Spacer()
            if let url = imgUrl {
                AsyncImage(url: url) { img in
                    img.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: 70, maxHeight: 70)
                        .clipShape(Circle())
                } placeholder: {
                    LoadingView()
                        .frame(maxWidth: 70, maxHeight: 70)
                }
            }
            TextField("", text: $headerText, axis: .vertical)
                .font(.title)
                .fontWeight(.heavy)
                .padding()
                .disabled(!isEditing)
            Spacer()
        }
        .editableToolbar(isEditing: $isEditing,
                         url: siteUrl,
                         saveAction: saveAction,
                         cancelAction: cancelAction,
                         deleteAction: deleteAction)
    }
}
