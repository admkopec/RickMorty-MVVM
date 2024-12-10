//
//  OnboardingView.swift
//  RickMorty
//
//  Created by Adam Kopeć on 09/06/2024.
//

import SwiftUI

struct OnboardingView: View {
    @Binding
    var isPresented: Bool
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Color.gray
                Text("App Icon")
                    .foregroundStyle(.white)
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .defaultShadow()
            .padding(.bottom)
            
            Text("Welcome to Rick & Morty")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom)
            Text("This is a simple app that uses the Rick & Morty API to display characters from the show.")
                .multilineTextAlignment(.center)
                .padding(.bottom)
            
            GroupBox {
                VStack(alignment: .leading) {
                    Text("You can view details about each character and mark them as favourites by clicking the heart icon.")
                        .multilineTextAlignment(.leading)
                        .padding(.bottom)
                    Text("You can use the search bar to find your favourite character!")
                        .multilineTextAlignment(.leading)
                        .padding(.bottom)
                    Text("Click the button below to view characters!")
                }
            }
            
            Spacer()
            
            Button {
                withAnimation {
                    isPresented = false
                }
            } label: {
                Label("Get Started", systemImage: "chevron.down")
                    .foregroundStyle(.white)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(Capsule())
        }
        .padding()
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
