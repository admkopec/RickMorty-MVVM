//
//  Shadows.swift
//  RickMorty
//
//  Created by Adam Kopeć on 09/06/2024.
//

import SwiftUI

extension View {
    /// Adds a shadow to the view with radius of 10 poins and y offset of 4 points..
    func defaultShadow() -> some View {
        shadow(radius: 10, y: 4)
    }
}
