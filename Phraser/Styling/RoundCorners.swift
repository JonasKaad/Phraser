//
//  RoundCorners.swift
//  Phraser
//
//  Created by Jonas Kaad on 13/11/2024.
//
import SwiftUI



struct RoundCorner: ViewModifier {
    var color: Color
    var lineWidth: CGFloat
    var cornerRadius: CGFloat
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(color)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: lineWidth)
            )
    }
}

struct RoundCornerWithoutBG: ViewModifier {
    var color: Color
    var lineWidth: CGFloat
    var cornerRadius: CGFloat
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: lineWidth)
            )
    }
}

extension View {
    func roundedCorners(
            color: Color = .blue,
            lineWidth: CGFloat = 1.6,
            cornerRadius: CGFloat = 14
        ) -> some View {
            modifier(RoundCorner(color: color, lineWidth: lineWidth, cornerRadius: cornerRadius))
        }
    func roundedCornersWithoutBG(
            color: Color = .blue,
            lineWidth: CGFloat = 1.6,
            cornerRadius: CGFloat = 14
        ) -> some View {
            modifier(RoundCornerWithoutBG(color: color, lineWidth: lineWidth, cornerRadius: cornerRadius))
        }
}
