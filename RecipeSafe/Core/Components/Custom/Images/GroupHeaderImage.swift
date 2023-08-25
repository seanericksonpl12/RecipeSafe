//
//  GroupHeaderImage.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/17/23.
//

import SwiftUI

struct GroupHeaderImage: View {
    
    @Binding var group: GroupModel
    
    var body: some View {
        if let url = group.imgUrl {
            CachedAsyncImage(url: url) { phase in
                switch phase {
                case.empty:
                    ColorSet.color(group.dataEntity.color)
                        .scaledToFill()
                        .ignoresSafeArea()
                        .opacity(0.75)
                        .allowsHitTesting(false)
                        .zIndex(0)
                case .failure(_):
                    ColorSet.color(group.dataEntity.color)
                        .scaledToFill()
                        .ignoresSafeArea()
                        .opacity(0.75)
                        .allowsHitTesting(false)
                        .zIndex(0)
                case .success(let img):
                    img
                        .resizable()
                        .scaledToFill()
                        .opacity(0.85)
                        .allowsHitTesting(false)
                        .zIndex(0)
                @unknown default:
                    ColorSet.color(group.dataEntity.color)
                        .scaledToFill()
                        .ignoresSafeArea()
                        .opacity(0.75)
                        .allowsHitTesting(false)
                        .zIndex(0)
                }
            }
        }
        else {
            ColorSet.color(group.dataEntity.color)
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.75)
                .allowsHitTesting(false)
                .zIndex(0)
        }
    }
}
