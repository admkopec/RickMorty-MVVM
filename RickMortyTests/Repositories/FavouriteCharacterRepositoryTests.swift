//
//  FavouriteCharacterRepositoryTests.swift
//  RickMortyTests
//
//  Created by Adam Kopeć on 09/06/2024.
//

import XCTest
import CoreData
@testable import RickMorty

final class FavouriteCharacterRepositoryTests: XCTestCase {
    
    private var sut: FavouriteCharacterRepositoryImpl!
    private var testContext: NSManagedObjectContext!
    
    override func setUp() async throws {
        testContext = await PersistenceController.testing.container.viewContext
        sut = FavouriteCharacterRepositoryImpl(context: testContext)
    }
    
    func testFetchingFavouriteCharacterIds() async throws {
        // When
        let favouriteCharacterIds = try await sut.fetchFavouriteCharacterIds()
        // Then
        XCTAssertEqual(favouriteCharacterIds.sorted(), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    }
    
    func testAddingFavouriteCharacter() async throws {
        // When
        try await sut.addFavourite(for: 10)
        // Then
        let favouriteCharacterIds = try await sut.fetchFavouriteCharacterIds()
        XCTAssertEqual(favouriteCharacterIds.sorted(), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    }
    
    func testRemovingFavouriteCharacter() async throws {
        // When
        try await sut.removeFavourite(for: 9)
        // Then
        let favouriteCharacterIds = try await sut.fetchFavouriteCharacterIds()
        XCTAssertEqual(favouriteCharacterIds.sorted(), [0, 1, 2, 3, 4, 5, 6, 7, 8])
    }
    
    func testCheckingIfCharacterIsFavourite() async throws {
        // When
        let isFavourite = try await sut.fetchIsFavourite(for: 1)
        // Then
        XCTAssertTrue(isFavourite)
    }
    
    func testCheckingIfCharacterIsNotFavourite() async throws {
        // When
        let isFavourite = try await sut.fetchIsFavourite(for: 20)
        // Then
        XCTAssertFalse(isFavourite)
    }
    
    func testFavouriteCharactersPublisher() async throws {
        // Given
        let expect = expectation(description: "Publisher emits value")
        let publisher = sut.favouriteCharactersPublisher()
        let cancellable = publisher.sink { _ in
            expect.fulfill()
        }
        
        // When
        try await sut.addFavourite(for: 20)
        
        // Then
        await fulfillment(of: [expect])
        
        cancellable.cancel()
    }
}

extension PersistenceController {
    @MainActor
    static var testing: PersistenceController {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<10 {
            let newItem = FavouriteCharacter(context: viewContext)
            newItem.characterId = Int32(i)
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }
}
