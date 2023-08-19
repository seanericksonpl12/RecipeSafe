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
            .frame(width: (geoProxy.size.width / 2.75), height: (geoProxy.size.width / 2.75))
            .background {
                if let url = group.imgUrl {
                    CachedAsyncImage(url: url) { phase in
                        switch phase {
                        case.empty:
                            Color(.secondarySystemFill)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        case .failure(_):
                            Color(.secondarySystemFill)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        case .success(let img):
                            img
                                .resizable()
                                .scaledToFill()
                                .frame(width: (geoProxy.size.width / 2.75), height: (geoProxy.size.width / 2.75))
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .opacity(0.5)
                                .allowsHitTesting(false)
                                .zIndex(0)
                        @unknown default:
                            Color(.secondarySystemFill)
                        }
                    }
                } else {
                    Color(.secondarySystemFill)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                   
            }
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
