//
//  RickMortyAPIServiceMock.swift
//  RickMorty
//
//  Created by Adam Kopeć on 11/12/2024.
//

import XCTest
@testable import RickMorty

class RickMortyAPIServiceMock: RickMortyAPIService {
    
    var error: APIError?
    var moreAvailable = false
    
    var fetchCharactersCalled = false
    var fetchCharactersCalledWithPage: Int?
    var fetchCharactersCalledWithSearchQuery: String?
    var fetchEpisodeIdCalled = false
    var fetchEpisodeUrlCalled = false
    
    var expect: [XCTestExpectation] = []
    
    func fetchCharacters(page: Int?, with searchQuery: String) async throws -> ([Character], moreAvailable: Bool) {
        fetchCharactersCalled = true
        fetchCharactersCalledWithPage = page
        fetchCharactersCalledWithSearchQuery = searchQuery
        if let expectation = expect.first {
            expectation.fulfill()
            expect.removeFirst()
        }
        if let error = error {
            throw error
        }
        return ([Character.preview], moreAvailable)
    }
    
    func fetchEpisode(id: Int) async throws -> Episode {
        fetchEpisodeIdCalled = true
        if let expectation = expect.first {
            expectation.fulfill()
            expect.removeFirst()
        }
        if let error = error {
            throw error
        }
        return Episode.preview
    }
    
    func fetchEpisode(url: URL) async throws -> Episode {
        fetchEpisodeUrlCalled = true
        if let expectation = expect.first {
            expectation.fulfill()
            expect.removeFirst()
        }
        if let error = error {
            throw error
        }
        return Episode.preview
    }
}
