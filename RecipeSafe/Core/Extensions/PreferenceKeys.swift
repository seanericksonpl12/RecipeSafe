//
//  PreferenceKeys.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/19/24.
//

import Foundation
import SwiftUI

struct SizePreferenceKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizeModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { proxy in
                    Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
                }
            }
    }
}

extension View {
    func onSizePreferenceChange(_ perform: @escaping (CGSize) -> ())  -> some View {
        self.modifier(SizeModifier()).onPreferenceChange(SizePreferenceKey.self, perform: { perform($0) })
    }
}
