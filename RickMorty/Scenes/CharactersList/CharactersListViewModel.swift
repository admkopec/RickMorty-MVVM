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
    
    // MARK: - State
    
    @Published var characters: [Character] = []
    @Published var searchQuery: String = ""
    @Published var isLoading = false
    @Published var didReachEnd = false
    @Published var errorMessage: String?
    
    private var currentPage = 0
    
    // MARK: - Actions
    
    func onAppearActions() {
        fetchNextPage()
    }
    
    func fetchNextPage() {
        guard !isLoading else { return }
        isLoading = true
        Task {
            let nextPage = currentPage + 1
            do {
                let (characters, moreAvailable) = try await apiService.fetchCharacters(page: nextPage, with: searchQuery)
                self.characters.append(contentsOf: characters)
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
    
    // MARK: - Setup
    
    private func setup() {
        $searchQuery.debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.currentPage = 0
                self?.characters = []
                self?.didReachEnd = false
                self?.fetchNextPage()
            }
            .store(in: &cancellables)
    }
    
    init() {
        self.apiService = RickMortyAPIService()
        
        setup()
    }
}
