//
//  MainView.swift
//  RickMorty
//
//  Created by Adam Kopeć on 08/06/2024.
//

import SwiftUI

struct MainView: View {
    @State
    private var isShowingOnboarding = true
    
    var body: some View {
        if isShowingOnboarding {
            OnboardingView(isPresented: $isShowingOnboarding)
                .transition(AnyTransition.move(edge: .top))
        } else {
            NavigationStack {
                CharactersListView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                withAnimation {
                                    isShowingOnboarding = true
                                }
                            } label: {
                                Image(systemName: "chevron.up")
                                    .font(.body.bold())
                            }
                            .buttonStyle(.bordered)
                            .clipShape(Circle())
                        }
                    }
                    .navigationDestination(for: Character.self) { character in
                        CharacterDetailsView(character: character)
                    }
                    .navigationDestination(for: Episode.self) { episode in
                        EpisodeDetailsView(episode: episode)
                    }
            }
            .transition(AnyTransition.move(edge: .bottom))
        }
    }
}

#Preview {
    MainView()
}
