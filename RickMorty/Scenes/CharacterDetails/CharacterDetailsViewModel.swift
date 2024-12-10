//
//  CharacterDetailsViewModel.swift
//  RickMorty
//
//  Created by Adam Kopeć on 10/12/2024.
//

import SwiftUI

@MainActor
class CharacterDetailsViewModel: ObservableObject {
    
    private let character: Character
    
    private var apiService: RickMortyAPIService
    private var repository: FavouriteCharacterRepository
    
    // MARK: - State
    
    @Published var name: String = ""
    @Published var imageUrl: URL = URL(fileURLWithPath: "")
    @Published var status: String = ""
    @Published var statusSymbol: String = ""
    @Published var gender: String = ""
    @Published var genderSymbol: String = ""
    @Published var origin: String = ""
    @Published var location: String = ""
    
    @Published var isFavourite: Bool = false
    
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var episodes: [Episode] = []
    
    // MARK: - Actions
    
    func onAppearActions() {
        fetchEpisodes()
        fetchIsFavourite()
    }
    
    func toggleFavourite() {
        Task {
            if isFavourite {
                try await repository.removeFavourite(for: character.id)
                isFavourite = false
            } else {
                try await repository.addFavourite(for: character.id)
                isFavourite = true
            }
        }
    }
    
    func fetchIsFavourite() {
        Task {
            isFavourite = try await repository.fetchIsFavourite(for: character.id)
        }
    }
    
    func fetchEpisodes() {
        Task {
            isLoading = true
            do {
                episodes = try await character.episode.asyncMap({ try await self.apiService.fetchEpisode(url: $0) })
            } catch let apiError as APIError {
                errorMessage = apiError.message
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    // MARK: - Display Logic
    
    func displayCharacter(character: Character) {
        name = character.name
        imageUrl = character.image
        status = character.status
        gender = character.gender
        origin = character.origin.name
        location = character.location.name
        
        if status == "Alive" {
            statusSymbol = "heart.fill"
        } else if status == "Dead" {
            statusSymbol = "heart.slash.fill"
        } else {
            statusSymbol = "questionmark"
        }
        
        if gender == "Male" {
            genderSymbol = "♂︎"
        } else if gender == "Female" {
            genderSymbol = "♀︎"
        } else {
            genderSymbol = ""
        }
    }
    
    // MARK: - Setup
    
    init(character: Character) {
        self.character = character
        self.apiService = RickMortyAPIService()
        self.repository = FavouriteCharacterRepository()
        
        displayCharacter(character: character)
    }
}


