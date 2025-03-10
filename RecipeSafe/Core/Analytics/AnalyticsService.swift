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
        case deviceModel
        case deviceName
        case deviceLocalizedModel
        case deviceSystemName
        case deviceSystemVersion
        case deviceType
        case screenWidth
        case screenHeight
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
    
    let trackAction: (AnalyticsAction, [String: String], [PageName]) -> Void
    let trackPageLoad: ([PageName]) -> Void
    var currentPath: [PageName] = []
}

extension AnalyticsService {
    static var defaultValue: Self { .mock }
    
    static var live: Self {
        let client = SimpleAnalytics(hostname: AppEnvironment.analyticsHostname!)
        return .init(
            trackAction: { action, data, path in
                Task { @Sendable in
                    client.track(event: action.rawValue, path: path.map(\.rawValue), metadata: await metadata(adding: data))
                    Logger.log("tracking action: \(action) for path: \(path.map(\.rawValue))")
                }
            },
            trackPageLoad: { pages in
                Task { @Sendable in
                    client.track(path: pages.map(\.rawValue), metadata: await metadata(adding: [:]))
                    Logger.log("tracking path: \(pages.map(\.rawValue))")
                }
            }
        )
    }
    
    static func metadata(adding dictionary: [String: String]) async -> [String: String] {
        let device = await UIDevice.current
        let screen = await UIScreen.main.bounds
        return await [
            Metadata.userId.rawValue: uniqueId,
            Metadata.deviceName.rawValue: device.name,
            Metadata.deviceType.rawValue: device.userInterfaceIdiom == .phone ? "iPhone" : "iPad",
            Metadata.deviceModel.rawValue: device.model,
            Metadata.deviceLocalizedModel.rawValue: device.localizedModel,
            Metadata.deviceSystemName.rawValue: device.systemName,
            Metadata.deviceSystemVersion.rawValue: device.systemVersion,
            Metadata.screenWidth.rawValue: "\(screen.width)",
            Metadata.screenHeight.rawValue: "\(screen.height)"
        ]
            .merging(dictionary, uniquingKeysWith: { "\($0)/\($1)" })
    }
    
    static var mock: Self {
        .init(
            trackAction: { event, data, path in
                Logger.log("Event tracked: \(event) with path: \(path)")
            },
            trackPageLoad: {
                Logger.log("Page loaded: \($0)")
            }
        )
    }
}

extension AnalyticsService {
    
    func trackAction(_ action: AnalyticsAction, metadata: [String: String] = [:], path: [PageName]? = nil) {
        self.trackAction(action, metadata, path ?? self.currentPath)
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

extension View {
    
    func pageLoad(_ pageName: PageName) -> some View {
        self.modifier(TrackPageLoadModifier(page: pageName))
    }
}
