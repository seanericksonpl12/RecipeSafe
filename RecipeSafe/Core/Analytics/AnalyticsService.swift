//
//  AnalyticsService.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/26/25.
//

import SwiftUI

@preconcurrency import SimpleAnalytics

enum AnalyticsAction: String {
    case tappedCreateNewRecipe
    case tappedCreateNewRecipeFromPhotos
    case tappedCreateNewRecipeFromCamera
    case tappedAddToGroup
    case tappedAddToShoppingList
    case tappedNewGroup
    case tappedEdit
}

enum PageName: String {
    case root
    case allRecipes
    case groups
    case group
    case shoppingList
    case tutorial
    case recipe
}

struct AnalyticsService: Service {
    
    enum Metadata: String {
        case userId
    }
    
    static var uniqueId: String {
        let key = "RECIPE_SAFE_ANALYTICS_UUID"
        if let id = UserDefaults.standard.string(forKey: key) {
            return id
        } else {
            let id = UUID().uuidString
            UserDefaults.standard.set(id, forKey: key)
            return id
        }
    }
    
    let trackAction: (AnalyticsAction, [PageName]) -> Void
    let trackPageLoad: ([PageName]) -> Void
    var currentPath: [PageName] = []
}

extension AnalyticsService {
    static var defaultValue: Self { .mock }
    
    static var live: Self {
        let client = SimpleAnalytics(hostname: AppEnvironment.analyticsHostname!)
        return .init(
            trackAction: { action, path in
                Logger.log("tracking action: \(action)")
                client.track(event: action.rawValue, path: path.map(\.rawValue), metadata: metadata())
            },
            trackPageLoad: { pages in
                Logger.log("tracking path: \(pages.map(\.rawValue))")
                client.track(path: pages.map(\.rawValue), metadata: metadata())
            }
        )
    }
    
    static func metadata() -> [String: String] {
        [Metadata.userId.rawValue: uniqueId]
    }
    
    static var mock: Self {
        .init(
            trackAction: {
                Logger.log("Event tracked: \($0) with path: \($1)")
            },
            trackPageLoad: {
                Logger.log("Page loaded: \($0)")
            }
        )
    }
}

struct TrackPageLoadModifier: ViewModifier {
    @Environment(\.services.analytics) var analytics
    
    let page: PageName
    
    func body(content: Content) -> some View {
        content
            .onAppear { analytics.trackPageLoad(analytics.currentPath + [page]) }
            .environment(\.services.analytics.currentPath, analytics.currentPath + [page])
    }
}

struct TrackTappedActionModifier: ViewModifier {
    @Environment(\.services.analytics) var analytics
    
    let action: AnalyticsAction
    
    func body(content: Content) -> some View {
        content.buttonStyle(.additionAction {
            analytics.trackAction(action, analytics.currentPath)
        })
    }
}

extension View {
    
    func pageLoad(_ pageName: PageName) -> some View {
        self.modifier(TrackPageLoadModifier(page: pageName))
    }
    
    func sendAction(_ action: AnalyticsAction) -> some View {
        self.modifier(TrackTappedActionModifier(action: action)).buttonStyle(.automatic)
    }
}


extension ButtonStyle where Self == AdditionalActionButtonStyle {
    static func additionAction(_ action: @escaping () -> Void) -> Self {
        return Self(action: action)
    }
}

struct AdditionalActionButtonStyle: ButtonStyle {
    
    let action: () -> Void
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label.onChange(of: configuration.isPressed) { _, newValue in
            if newValue {
                self.action()
            }
        }
    }
}
