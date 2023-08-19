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
            .stroke(.gray, lineWidth: 4)
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
                                .opacity(isEditing ? 0.5 : 1)
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
                VStack {
                    Spacer()
                    HStack {
                        Text(group.title ?? "" )
                            .lineLimit(1)
                            .fontWeight(.heavy)
                            .foregroundColor(.black)
                            .padding(EdgeInsets(top: 2, leading: 10, bottom: 0, trailing: 10))
                            .background {
                                LeftTabbedRoundedRectangle(radius: 7, leftRadius: 11)
                                    .fill(.gray)
                                    .padding(EdgeInsets(top: 0, leading: 2, bottom: -3, trailing: 0))
                                    .zIndex(-1)
                            }
                        Spacer()
                    }
                    .padding(.bottom, 5)
                }
            }
            .padding()
    }
}