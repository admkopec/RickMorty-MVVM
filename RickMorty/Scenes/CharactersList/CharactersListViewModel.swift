//
//  CharactersListViewModel.swift
//  RickMorty
//
//  Created by Adam Kopeć on 10/12/2024.
//

import SwiftUI
import Combine

@MainActor
class CharactersListViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    
    private let apiService: RickMortyAPIService
    private let repository: FavouriteCharacterRepository
    
    // MARK: - State
    
    @Published var characters: [Character] = []
    @Published var searchQuery: String = ""
    @Published var isLoading = false
    @Published var didReachEnd = false
    @Published var errorMessage: String?
    @Published var showOnlyFavourites = false
    
    private var currentPage = 0
    
    // MARK: - Actions
    
    func onAppearActions() {
        if showOnlyFavourites {
            fetchFavouriteCharacters()
        } else {
            fetchNextPage()
        }
    }
    
    func fetchNextPage() {
        guard !isLoading, !showOnlyFavourites else { return }
        isLoading = true
        Task {
            let nextPage = currentPage + 1
            do {
                let (characters, moreAvailable) = try await apiService.fetchCharacters(page: nextPage, with: searchQuery)
                withAnimation {
                    self.characters.append(contentsOf: characters)
                }
                currentPage = nextPage
                didReachEnd = !moreAvailable
                errorMessage = nil
            } catch let apiError as APIError {
                errorMessage = apiError.message
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func fetchFavouriteCharacters() {
        isLoading = true
        Task {
            do {
                let favouriteCharacterIds = try await repository.fetchFavouriteCharacterIds()
                let characters = try await favouriteCharacterIds.asyncMap { id in
                    try await self.apiService.fetchCharacter(id: id)
                }.filter({ $0.name.lowercased().contains(searchQuery.lowercased()) || searchQuery.isEmpty })
                withAnimation {
                    self.characters = characters
                }
                didReachEnd = true
            } catch let apiError as APIError {
                errorMessage = apiError.message
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func toggleFavouritesFilter() {
        showOnlyFavourites.toggle()
        if showOnlyFavourites {
            fetchFavouriteCharacters()
        } else {
            currentPage = 0
            didReachEnd = false
            characters = []
            fetchNextPage()
        }
    }
        
    
    // MARK: - Setup
    
    private func setup() {
        $searchQuery.debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.currentPage = 0
                self?.characters = []
                self?.didReachEnd = false
                if self?.showOnlyFavourites == true {
                    self?.fetchFavouriteCharacters()
                } else {
                    self?.fetchNextPage()
                }
            }
            .store(in: &cancellables)
    }
    
    init(apiService: RickMortyAPIService = RickMortyAPIServiceImpl(), repository: FavouriteCharacterRepository = FavouriteCharacterRepositoryImpl()) {
        self.apiService = apiService
        self.repository = repository
        
        setup()
    }
}
