//
//  FavouriteCharacterRepositoryMock.swift
//  RickMorty
//
//  Created by Adam Kopeć on 11/12/2024.
//

import XCTest
import Combine
@testable import RickMorty

class FavouriteCharacterRepositoryMock: FavouriteCharacterRepository {
    var favouriteCharacterIds: Set<Int> = []
    
    var fetchFavouriteCharacterIdsCalled = false
    var fetchIsFavouriteCalled = false
    var addFavouriteCalled = false
    var removeFavouriteCalled = false
    var favouriteCharactersPublisherCalled = false
    
    var expect: [XCTestExpectation] = []
    var publisher: PassthroughSubject<Notification, Never> = PassthroughSubject()
    
    func fetchFavouriteCharacterIds() async throws -> [Int] {
        fetchFavouriteCharacterIdsCalled = true
        if let expectation = expect.first {
            expectation.fulfill()
            expect.removeFirst()
        }
        return Array(favouriteCharacterIds)
    }
    
    func fetchIsFavourite(for characterId: Int) async throws -> Bool {
        fetchIsFavouriteCalled = true
        if let expectation = expect.first {
            expectation.fulfill()
            expect.removeFirst()
        }
        return favouriteCharacterIds.contains(characterId)
    }
    
    func addFavourite(for characterId: Int) async throws {
        addFavouriteCalled = true
        if let expectation = expect.first {
            expectation.fulfill()
            expect.removeFirst()
        }
        favouriteCharacterIds.insert(characterId)
    }
    
    func removeFavourite(for characterId: Int) async throws {
        removeFavouriteCalled = true
        if let expectation = expect.first {
            expectation.fulfill()
            expect.removeFirst()
        }
        favouriteCharacterIds.remove(characterId)
    }
    
    func favouriteCharactersPublisher() -> AnyPublisher<Notification, Never> {
        favouriteCharactersPublisherCalled = true
        if let expectation = expect.first {
            expectation.fulfill()
            expect.removeFirst()
        }
        return publisher.eraseToAnyPublisher()
    }
}
