//
//  CharacterDetailsViewModelTests.swift
//  RickMortyTests
//
//  Created by Adam Kopeć on 10/12/2024.
//

import XCTest
@testable import RickMorty

final class CharacterDetailsViewModelTests: XCTestCase {
    
    private var character = Character.preview
    private var sut: CharacterDetailsViewModel!
    private var apiService: RickMortyAPIServiceMock!
    private var repository: FavouriteCharacterRepositoryMock!

    override func setUp() async throws {
        apiService = RickMortyAPIServiceMock()
        repository = FavouriteCharacterRepositoryMock()
        sut = await CharacterDetailsViewModel(character: character, apiService: apiService, repository: repository)
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
    func testFetchEpisodesOnLoad() async throws {
        // Given
        let expect = [expectation(description: "Fetch episodes")]
        apiService.expect = expect
        
        // When
        loadView()
        
        // Then
        XCTAssertTrue(sut.isLoading)
        
        await fulfillment(of: expect)
        
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(sut.episodes.count, character.episode.count)
        XCTAssertTrue(apiService.fetchEpisodeUrlCalled)
        XCTAssertNil(sut.errorMessage)
    }
    
    @MainActor
    func testFetchIsFavourite() async throws {
        // Given
        let expect = [expectation(description: "Fetch is favourite")]
        repository.favouriteCharacterIds = [character.id]
        repository.expect = expect
        
        // When
        sut.fetchIsFavourite()
        
        await fulfillment(of: expect)
        
        // Then
        XCTAssertTrue(sut.isFavourite)
        XCTAssertTrue(repository.fetchIsFavouriteCalled)
    }
    
    @MainActor
    func testFetchEpisodes() async throws {
        // Given
        let expect = [expectation(description: "Fetch episodes")]
        apiService.expect = expect
        
        // When
        sut.fetchEpisodes()
                
        // Then
        XCTAssertTrue(sut.isLoading)
        
        await fulfillment(of: expect)

        XCTAssertEqual(sut.episodes.count, character.episode.count)
        XCTAssertTrue(apiService.fetchEpisodeUrlCalled)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }
    
    @MainActor
    func testFetchEpisodesError() async throws {
        // Given
        let expect = [expectation(description: "Fetch episodes")]
        apiService.error = APIError(message: "Error")
        apiService.expect = expect
        
        // When
        sut.fetchEpisodes()
                
        // Then
        XCTAssertTrue(sut.isLoading)
        
        await fulfillment(of: expect)

        XCTAssertEqual(sut.episodes.count, 0)
        XCTAssertTrue(apiService.fetchEpisodeUrlCalled)
        XCTAssertEqual(sut.errorMessage, "Error")
        XCTAssertFalse(sut.isLoading)
    }
    
    @MainActor
    func testToggleFavouriteAdd() async throws {
        // Given
        sut.isFavourite = false
        let expect = [expectation(description: "Toggle favourite")]
        repository.expect = expect
        
        // When
        sut.toggleFavourite()
        
        await fulfillment(of: expect)
        
        // Then
        XCTAssertTrue(repository.addFavouriteCalled)
        XCTAssertTrue(sut.isFavourite)
    }
    
    @MainActor
    func testToggleFavouriteRemove() async throws {
        // Given
        sut.isFavourite = true
        let expect = [expectation(description: "Toggle favourite")]
        repository.expect = expect
        
        // When
        sut.toggleFavourite()
        
        await fulfillment(of: expect)
        
        // Then
        XCTAssertTrue(repository.removeFavouriteCalled)
        XCTAssertFalse(sut.isFavourite)
    }
    
    @MainActor
    func testDisplayCharacter() async throws {
        // Given
        let character = Character.preview
        sut.name = ""
        sut.imageUrl = URL(string: "https://example.com")!
        sut.status = ""
        sut.gender = ""
        sut.origin = ""
        sut.location = ""
        
        // When
        sut.displayCharacter(character: character)
        
        // Then
        XCTAssertEqual(sut.name, character.name)
        XCTAssertEqual(sut.imageUrl, character.image)
        XCTAssertEqual(sut.status, character.status)
        XCTAssertEqual(sut.gender, character.gender)
        XCTAssertEqual(sut.origin, character.origin.name)
        XCTAssertEqual(sut.location, character.location.name)
    }
    
    @MainActor
    func testDisplayAliveCharacter() async throws {
        // Given
        let character = Character(id: character.id, name: character.name, status: "Alive", gender: character.gender, origin: character.origin, location: character.location, image: character.image, episode: character.episode)
        
        // When
        sut.displayCharacter(character: character)
        
        // Then
        XCTAssertEqual(sut.status, character.status)
        XCTAssertEqual(sut.statusSymbol, "heart.fill")
    }
    
    @MainActor
    func testDisplayDeadCharacter() async throws {
        // Given
        let character = Character(id: character.id, name: character.name, status: "Dead", gender: character.gender, origin: character.origin, location: character.location, image: character.image, episode: character.episode)
        
        // When
        sut.displayCharacter(character: character)
        
        // Then
        XCTAssertEqual(sut.status, character.status)
        XCTAssertEqual(sut.statusSymbol, "heart.slash.fill")
    }
    
    @MainActor
    func testDisplayUnknownStatusCharacter() async throws {
        // Given
        let character = Character(id: character.id, name: character.name, status: "Unknown", gender: character.gender, origin: character.origin, location: character.location, image: character.image, episode: character.episode)
        
        // When
        sut.displayCharacter(character: character)
        
        // Then
        XCTAssertEqual(sut.status, character.status)
        XCTAssertEqual(sut.statusSymbol, "questionmark")
    }
    
    @MainActor
    func testDisplayMaleCharacter() async throws {
        // Given
        let character = Character(id: character.id, name: character.name, status: character.status, gender: "Male", origin: character.origin, location: character.location, image: character.image, episode: character.episode)
        
        // When
        sut.displayCharacter(character: character)
        
        // Then
        XCTAssertEqual(sut.gender, character.gender)
        XCTAssertEqual(sut.genderSymbol, "♂︎")
    }

    @MainActor
    func testDisplayFemaleCharacter() async throws {
        // Given
        let character = Character(id: character.id, name: character.name, status: character.status, gender: "Female", origin: character.origin, location: character.location, image: character.image, episode: character.episode)
        
        // When
        sut.displayCharacter(character: character)
        
        // Then
        XCTAssertEqual(sut.gender, character.gender)
        XCTAssertEqual(sut.genderSymbol, "♀︎")
    }
}
