//
//  LeftTabbedRoundedRectangle.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/19/23.
//

import SwiftUI

struct LeftTabbedRoundedRectangle: Shape {
    
    let radius: CGFloat
    let leftRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let startPoint = CGPoint(x: rect.minX, y: rect.minY + radius)
        path.move(to: startPoint)
        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY - radius),
                    radius: radius,
                    startAngle: Angle(degrees: -180),
                    endAngle: Angle(degrees: -270),
                    clockwise: true)
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                    radius: radius,
                    startAngle: Angle(degrees: 270),
                    endAngle: Angle(degrees: 360),
                    clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addArc(center: CGPoint(x: rect.maxX + radius, y: rect.maxY - radius),
                    radius: radius,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 90),
                    clockwise: true)
        path.addLine(to: CGPoint(x: rect.minX + leftRadius, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + leftRadius, y: rect.maxY - leftRadius),
                    radius: leftRadius,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 180),
                    clockwise: false)
        path.addLine(to: startPoint)
        return path

    }
}
