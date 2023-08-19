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
                    Image("logo-background")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .opacity(0.5)
                        .allowsHitTesting(false)
                        .zIndex(0)
                case .failure(_):
                    Image("logo-background")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .opacity(0.5)
                        .allowsHitTesting(false)
                        .zIndex(0)
                case .success(let img):
                    img
                        .frame(maxHeight: 40)
                        .opacity(0.5)
                        .allowsHitTesting(false)
                        .zIndex(0)
                @unknown default:
                    Image("logo-background")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .opacity(0.5)
                        .allowsHitTesting(false)
                        .zIndex(0)
                }
            }
        }
        else {
            Image("logo-background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.5)
                .allowsHitTesting(false)
                .zIndex(0)
        }
    }
}
