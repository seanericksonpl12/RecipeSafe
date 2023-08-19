//
//  InverseRoundedRectangle.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/18/23.
//

import SwiftUI

struct InverseRoundedRectangle: Shape {
    
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let startPoint = CGPoint(x: rect.minX - radius, y: rect.maxY)
        path.move(to: startPoint)
        path.addArc(center: CGPoint(x: rect.minX - radius, y: rect.maxY - radius),
                    radius: radius,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 360),
                    clockwise: true)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                    radius: radius,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 270),
                    clockwise: false)
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
        path.addLine(to: CGPoint(x: rect.minX - radius, y: rect.maxY))
        return path

    }
}

