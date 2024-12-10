//
//  GeometryModifier.swift
//  RickMorty
//
//  Created by Adam Kopeć on 09/06/2024.
//

import SwiftUI

struct GeometryModifier: ViewModifier {
    @Binding
    var size: CGSize
    
    func body(content: Content) -> some View {
        content.background {
            GeometryReader { geometry in
                Color.clear.onAppear {
                    size = geometry.size
                }.onChange(of: geometry.size) { _ in
                    size = geometry.size
                }
            }
        }
    }
}

extension View {
    /// A modifier that reads the size of the view into the binding.
    func geometry(size: Binding<CGSize>) -> some View {
        modifier(GeometryModifier(size: size))
    }
}
