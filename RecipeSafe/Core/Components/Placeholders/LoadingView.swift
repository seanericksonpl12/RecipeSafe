//
//  LoadingView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/24/23.
//

import SwiftUI

struct LoadingView: View {
    
    // MARK: - Body
    var body: some View {
        LottieView(animationName: "LoadingAnimation", speed: 1.5)
            .frame(width: 100)
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
