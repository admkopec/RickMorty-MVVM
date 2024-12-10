//
//  EpisodeDetailsView.swift
//  RickMorty
//
//  Created by Adam Kopeć on 08/06/2024.
//

import SwiftUI

struct EpisodeDetailsView: View {
    @StateObject
    private var viewModel: EpisodeDetailsViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                Text(viewModel.name)
                    .font(.title)
                Text(viewModel.episodeCode)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, Margin.large)
                GroupBox {
                    HStack {
                        Text("First aired")
                            .bold()
                        Spacer()
                        Text(viewModel.airDate)
                    }
                    HStack {
                        Text("Number of characters")
                            .bold()
                        Spacer()
                        Text(viewModel.numberOfCharacters, format: .number)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.episodeCode)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    init(episode: Episode) {
        _viewModel = StateObject(wrappedValue: EpisodeDetailsViewModel(episode: episode))
    }
}

#Preview {
    NavigationStack {
        EpisodeDetailsView(episode: .preview)
    }
}
