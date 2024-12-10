//
//  CharactersListView.swift
//  RickMorty
//
//  Created by Adam Kopeć on 08/06/2024.
//

import SwiftUI

struct CharactersListView: View {
    @StateObject
    private var viewModel = CharactersListViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.characters) { character in
                    NavigationLink(value: character) {
                        CharactersListItemView(character: character)
                    }
                    .buttonStyle(.plain)
                }
                if let errorMsg = viewModel.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .padding(.bottom, Margin.extraSmall)
                        Text("Could not load data!")
                            .font(.subheadline)
                            .bold()
                        Text(errorMsg)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                } else if viewModel.didReachEnd {
                    VStack {
                        Text("🎉")
                            .font(.headline)
                        Text("That's all!")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.top)
                } else if viewModel.isLoading {
                    ProgressView()
                } else {
                    ProgressView()
                        .onAppear {
                            viewModel.fetchNextPage()
                        }
                }
            }
            .padding()
            .onAppear {
                viewModel.onAppearActions()
            }
            .searchable(text: $viewModel.searchQuery, prompt: "Search by name")
        }
        .navigationTitle("Characters")
    }
}

#Preview {
    NavigationStack {
        CharactersListView()
    }
}
