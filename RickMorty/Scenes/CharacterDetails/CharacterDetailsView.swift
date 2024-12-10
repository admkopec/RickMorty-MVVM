//
//  CharacterDetailsView.swift
//  RickMorty
//
//  Created by Adam Kopeć on 08/06/2024.
//

import SwiftUI

struct CharacterDetailsView: View {
    @StateObject
    private var viewModel: CharacterDetailsViewModel
    
    @State
    private var size: CGSize = .zero
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Margin.large) {
                AsyncImage(url: viewModel.imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .defaultShadow()
                } placeholder: {
                    Color(uiColor: .systemFill)
                        .overlay(ProgressView())
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .defaultShadow()
                }
                .frame(maxWidth: .infinity)
                
                Text(viewModel.name)
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity)
                
                GroupBox(label: Label("Info", systemImage: "person.fill")) {
                    VStack {
                        HStack {
                            Text("Status")
                                .bold()
                            Spacer()
                            Text(viewModel.status)
                            Image(systemName: viewModel.statusSymbol)
                        }
                        .frame(minHeight: size.height)
                        HStack {
                            Text("Gender")
                                .bold()
                            Spacer()
                            
                            Text(viewModel.gender)
                            Text(viewModel.genderSymbol)
                                .font(.title)
                        }
                        .geometry(size: $size)
                        HStack {
                            Text("Origin")
                                .bold()
                            Spacer()
                            Text(viewModel.origin)
                                .multilineTextAlignment(.trailing)
                        }
                        .frame(minHeight: size.height)
                        HStack {
                            Text("Location")
                                .bold()
                            Spacer()
                            Text(viewModel.location)
                                .multilineTextAlignment(.trailing)
                        }
                        .frame(minHeight: size.height)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                GroupBox(label: Label("Episodes", systemImage: "tv")) {
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
                        .padding()
                    } else if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        VStack {
                            ForEach(viewModel.episodes) { episode in
                                NavigationLink(value: episode) {
                                    HStack {
                                        Text("Episode \(episode.episode)")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.horizontal, Margin.small)
                                    .padding(.vertical, Margin.extraSmall)
                                    .background {
                                        Color(uiColor: .secondarySystemBackground)
                                    }
                                }
                                .buttonStyle(.plain)
                                if episode != viewModel.episodes.last {
                                    Divider()
                                }
                            }
                        }
                        .padding(.top)
                    }
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.toggleFavourite()
                    } label: {
                        Image(systemName: viewModel.isFavourite ? "heart.fill" : "heart")
                            .foregroundStyle(.red)
                            .accessibilityLabel("Toggle Favourite")
                    }
                    .scaleEffect(viewModel.isFavourite ? 1.2 : 1)
                    .animation(.interpolatingSpring(stiffness: 170, damping: 10), value: viewModel.isFavourite)
                }
            }
            .onAppear {
                viewModel.onAppearActions()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    init(character: Character) {
        self._viewModel = StateObject(wrappedValue: CharacterDetailsViewModel(character: character))
    }
}

#Preview {
    NavigationStack {
        CharacterDetailsView(character: .preview)
    }
}
