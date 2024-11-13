//
//  RoundCorners.swift
//  Phraser
//
//  Created by Jonas Kaad on 13/11/2024.
//
import SwiftUI



struct RoundCorner: ViewModifier {
    var color: Color
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(color)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(color, lineWidth: 1.8)
            )
    }
}

extension View {
    func roundedCustomColorCorners(with color: Color) -> some View {
        modifier(RoundCorner(color: color))
    }
    
    func roundedBlueCorners() -> some View {
        modifier(RoundCorner(color: Color.blue))
    }
}
