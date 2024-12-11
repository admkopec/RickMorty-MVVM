//
//  RickMortyAPIService.swift
//  RickMorty
//
//  Created by Adam Kopeć on 10/12/2024.
//

import Foundation

protocol RickMortyAPIService {
    /// Fetches a list of characters from the API
    /// - Parameter page: The page number to fetch. If `nil`, fetches the first page.
    /// - Parameter searchQuery: The search query to filter the results by name.
    /// - Throws: Error if fetching from the API fails
    /// - Returns: Tuple containing an array of characters and a boolean indicating if there are more pages to fetch
    func fetchCharacters(page: Int?, with searchQuery: String) async throws -> ([Character], moreAvailable: Bool)
    
    /// Fetches an episode from the API
    /// - Parameter id: The ID of the episode to fetch
    /// - Throws: Error if fetching from the API fails
    /// - Returns: The fetched episode
    func fetchEpisode(id: Int) async throws -> Episode
    
    /// Fetches an episode from the API given its full URL
    /// - Parameter url: The URL of the episode to fetch
    /// - Throws: Error if fetching from the API fails
    /// - Returns: The fetched episode
    func fetchEpisode(url: URL) async throws -> Episode
}

class RickMortyAPIServiceImpl: RickMortyAPIService {
    private let baseURL = URL(string: "https://rickandmortyapi.com/api/")!
    private let session: URLSession
    
    func fetchCharacters(page: Int? = nil, with searchQuery: String) async throws -> ([Character], moreAvailable: Bool) {
        let url = baseURL.appendingPathComponent("character")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let pageQueryItem = URLQueryItem(name: "page", value: "\(page ?? 1)")
        if !searchQuery.isEmpty {
            components.queryItems = [pageQueryItem, URLQueryItem(name: "name", value: searchQuery)]
        } else {
            components.queryItems = [pageQueryItem]
        }
        let request = URLRequest(url: components.url!)
        
        let (data, _) = try await session.data(for: request)
        
        do {
            let response = try JSONDecoder().decode(APIResponse<Character>.self, from: data)
            if response.info.next == nil {
                // We reached the end of the list
                return (response.results, false)
            } else {
                // Still more to fetch
                return (response.results, true)
            }
        } catch {
            if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw APIError(message: apiError.error)
            } else {
                throw error
            }
        }
    }
    
    func fetchEpisode(id: Int) async throws -> Episode {
        let url = baseURL.appendingPathComponent("episode").appendingPathComponent("\(id)")
        return try await fetchEpisode(url: url)
    }
    
    func fetchEpisode(url: URL) async throws -> Episode {
        let request = URLRequest(url: url)
        
        let (data, _) = try await session.data(for: request)
        
        do {
            return try JSONDecoder().decode(Episode.self, from: data)
        } catch {
            if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw APIError(message: apiError.error)
            } else {
                throw error
            }
        }
    }
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
}
