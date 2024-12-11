//
//  CharactersListItemViewModelTests.swift
//  RickMortyTests
//
//  Created by Adam Kopeć on 11/12/2024.
//

import XCTest
@testable import RickMorty

final class CharactersListItemViewModelTests: XCTestCase {
    
    private let character = Character.preview
    private var sut: CharactersListItemViewModel!
    private var repository: FavouriteCharacterRepositoryMock!

    override func setUp() async throws {
        repository = FavouriteCharacterRepositoryMock()
        sut = await CharactersListItemViewModel(character: character, repository: repository)
    }
    
    @MainActor
    func loadView() {
        sut.onAppearActions()
    }

    @MainActor
    func testFetchIsFavouriteOnLoad() async throws {
        // Given
        let expect = [expectation(description: "Fetch is favourite")]
        repository.favouriteCharacterIds = [character.id]
        repository.expect = expect
        
        // When
        loadView()
        
        await fulfillment(of: expect)
        
        // Then
        XCTAssertTrue(sut.isFavourite)
        XCTAssertTrue(repository.fetchIsFavouriteCalled)
    }
    
    @MainActor
    func testFetchIsFavouriteOnPublish() async throws {
        // Given
        let expect = [expectation(description: "Fetch is favourite")]
        repository.favouriteCharacterIds = [character.id]
        repository.expect = expect
        
        // When
        repository.publisher.send(Notification(name: Notification.Name(rawValue: "FavouriteCharacterRepositoryMock")))
        
        await fulfillment(of: expect)
        
        // Then
        XCTAssertTrue(sut.isFavourite)
        XCTAssertTrue(repository.fetchIsFavouriteCalled)
    }

    @MainActor
    func testDisplayCharacter() {
        // Given
        let character = Character.preview
        sut.name = ""
        sut.imageUrl = URL(fileURLWithPath: "")
        
        // When
        sut.displayCharacter(character: character)
        
        // Then
        XCTAssertEqual(sut.name, character.name)
        XCTAssertEqual(sut.imageUrl, character.image)
    }
}
