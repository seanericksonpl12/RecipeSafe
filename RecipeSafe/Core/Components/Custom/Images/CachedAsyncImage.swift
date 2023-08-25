//
//  CachedAsyncImage.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/19/23.
//

import SwiftUI

struct CachedAsyncImage<Content: View>: View {
    
    private let url: URL
    private let content: (AsyncImagePhase) -> Content
    
    init(url: URL, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.content = content
    }
    
    var body: some View {
        if let img = ImageCache[url] {
            content(.success(img))
        } else {
            AsyncImage(url: url) { phase in
                render(phase)
            }
        }
    }
    
    private func render(_ phase: AsyncImagePhase) -> some View {
        switch phase {
        case .empty:
            break
        case .success(let image):
            ImageCache[url] = image
        case .failure(let error):
            print(String(describing: error))
        @unknown default:
            break
        }
        return content(phase)
    }
}

fileprivate class ImageCache {
    
    static private var cache: [URL : Image] = [:]
    static private var cacheChecker: [URL : Bool] = [:]
    static private var cacheAccessTimes: [URL : Int] = [:]
    static private let cacheLimit: Int = 15
    
    static subscript(url: URL) -> Image? {
        get {
            if cacheChecker[url] == false || cacheChecker[url] == nil { return nil }
            return cache[url]
        }
        set {
            for pair in cacheAccessTimes {
                cacheAccessTimes[pair.key] = pair.value + 1
            }
            
            if cache.count >= cacheLimit {
                if let toReplace = cacheAccessTimes.max(by: { $0.value < $1.value })?.key {
                    cache[toReplace] = newValue
                    cacheAccessTimes[toReplace] = 0
                }
            } else {
                cache[url] = newValue
                cacheAccessTimes[url] = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                cacheChecker[url] = true
            }
        }
    }
}
