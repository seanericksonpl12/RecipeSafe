//
//  IconImage.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/8/23.
//

import SwiftUI

struct IconImage: View {
    
    let isEditing: Bool
    let img: ImageData
    
    // MARK: - Body
    var body: some View {
        switch img {
        case .selected(let data):
            if let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 60, maxHeight: 60)
                    .clipShape(Circle())
                    .padding(.leading)
                    .opacity(isEditing ? 0.5 : 1)
                    .overlay(alignment: .center) {
                        if isEditing {
                            editingOverlay
                        }
                    }
            } else { if isEditing { noImage } }
        case .downloaded(let url):
            AsyncImage(url: url) { img in
                img.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 60, maxHeight: 60)
                    .clipShape(Circle())
                    .padding(.leading)
                    .opacity(isEditing ? 0.5 : 1)
                    .overlay(alignment: .center) {
                        if isEditing {
                            editingOverlay
                        }
                    }
            } placeholder: {
                LoadingView()
                    .frame(maxWidth: 60, maxHeight: 60)
                    .padding(.leading)
            }
        case .none:
            if isEditing { noImage }
        }
    }
    
    // MARK: - No Image Placeholder
    var noImage: some View {
        Image(systemName: "plus.circle")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: 60, maxHeight: 60)
            .clipShape(Circle())
            .padding(.leading)
    }
    
    // MARK: - Editing Overlay
    var editingOverlay: some View {
        Image(systemName: "square.and.pencil")
            .resizable()
            .frame(maxWidth: 30, maxHeight: 30)
            .aspectRatio(contentMode: .fill)
            .padding(.leading)
            .foregroundStyle(Color.gray)
    }
}
