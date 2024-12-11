//
//  CharactersListItemViewModel.swift
//  RickMorty
//
//  Created by Adam Kopeć on 10/12/2024.
//

import SwiftUI
import Combine

@MainActor
class CharactersListItemViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    
    private let character: Character
    
    private var repository: FavouriteCharacterRepository
    
    // MARK: - State
    
    @Published var name: String = ""
    @Published var imageUrl: URL = URL(fileURLWithPath: "")
    @Published var isFavourite: Bool = false
    
    // MARK: - Actions
    
    func onAppearActions() {
        fetchIsFavourite()
    }
    
    func fetchIsFavourite() {
        Task {
            isFavourite = try await repository.fetchIsFavourite(for: character.id)
        }
    }
    
    // MARK: - Display Logic
    
    func displayCharacter(character: Character) {
        name = character.name
        imageUrl = character.image
    }
    
    // MARK: - Setup
    
    private func setup() {
        displayCharacter(character: character)
        fetchIsFavourite()
        // Listen for changes so that isFavourite state updates when the user adds/removes a favourite character
        self.repository.favouriteCharactersPublisher().sink { [weak self] _ in
            self?.fetchIsFavourite()
        }.store(in: &cancellables)
    }
    
    init(character: Character,
         repository: FavouriteCharacterRepository = FavouriteCharacterRepositoryImpl()) {
        self.character = character
        self.repository = repository
        
        setup()
    }
}

