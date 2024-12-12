//
//  CharactersListViewModelTests.swift
//  RickMortyTests
//
//  Created by Adam Kopeć on 11/12/2024.
//

import XCTest
@testable import RickMorty

final class CharactersListViewModelTests: XCTestCase {
    
    private var sut: CharactersListViewModel!
    private var apiService: RickMortyAPIServiceMock!
    private var repository: FavouriteCharacterRepositoryMock!

    override func setUp() async throws {
        apiService = RickMortyAPIServiceMock()
        repository = FavouriteCharacterRepositoryMock()
        sut = await CharactersListViewModel(apiService: apiService, repository: repository)
    }
    
    @MainActor
    func loadView() {
        sut.onAppearActions()
    }

    @MainActor
    func testFetchInitialCharactersOnLoad() async throws {
        // Given
        let expect = [expectation(description: "Characters fetched")]
        apiService.expect = expect
        sut.showOnlyFavourites = false
        
        // When
        loadView()
        
        // Then
        XCTAssertTrue(sut.isLoading)
        
        await fulfillment(of: expect)
        
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.didReachEnd)
        XCTAssertTrue(apiService.fetchCharactersCalled)
        XCTAssertEqual(apiService.fetchCharactersCalledWithPage, 1)
        XCTAssertEqual(apiService.fetchCharactersCalledWithSearchQuery, "")
        XCTAssertEqual(sut.characters, [Character.preview])
        XCTAssertNil(sut.errorMessage)
    }
    
    @MainActor
    func testFetchInitialFavouritesCharactersOnLoad() async throws {
        // Given
        let expect = [expectation(description: "Characters fetched")]
        apiService.expect = expect
        repository.favouriteCharacterIds = [Character.preview.id]
        sut.showOnlyFavourites = true
        
        // When
        loadView()
        
        // Then
        XCTAssertTrue(sut.isLoading)
        
        await fulfillment(of: expect)
        
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.didReachEnd)
        XCTAssertTrue(apiService.fetchCharacterIdCalled)
        XCTAssertTrue(repository.fetchFavouriteCharacterIdsCalled)
        XCTAssertEqual(sut.characters, [Character.preview])
        XCTAssertNil(sut.errorMessage)
    }
    
    @MainActor
    func testFetchNextPageError() async throws {
        // Given
        let expect = [expectation(description: "Characters fetched")]
        apiService.error = APIError(message: "Error")
        apiService.expect = expect
        
        // When
        sut.fetchNextPage()
        
        // Then
        XCTAssertTrue(sut.isLoading)
        
        await fulfillment(of: expect)
        
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.didReachEnd)
        XCTAssertTrue(apiService.fetchCharactersCalled)
        XCTAssertEqual(apiService.fetchCharactersCalledWithPage, 1)
        XCTAssertEqual(apiService.fetchCharactersCalledWithSearchQuery, "")
        XCTAssertEqual(sut.characters, [])
        XCTAssertEqual(sut.errorMessage, "Error")
    }
    
    @MainActor
    func testFetchNextPageThrottle() async throws {
        // Given
        let expect = [expectation(description: "Characters fetched")]
        apiService.expect = expect
        
        // When
        sut.fetchNextPage()
        sut.fetchNextPage()
        sut.fetchNextPage()
        
        // Then
        XCTAssertTrue(sut.isLoading)
        
        await fulfillment(of: expect)
        
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.didReachEnd)
        XCTAssertTrue(apiService.fetchCharactersCalled)
        XCTAssertEqual(apiService.fetchCharactersCalledWithPage, 1)
        XCTAssertEqual(apiService.fetchCharactersCalledWithSearchQuery, "")
        XCTAssertEqual(sut.characters, [Character.preview])
        XCTAssertNil(sut.errorMessage)
    }
    
    @MainActor
    func testFetchCharactersOnSearchQueryChange() async throws {
        // Given
        let query = "Rick"
        let expect = [expectation(description: "Characters fetched")]
        apiService.expect = expect
        
        // When
        sut.searchQuery = query
        
        // Then
        await fulfillment(of: expect)
        
        XCTAssertTrue(apiService.fetchCharactersCalled)
        XCTAssertEqual(apiService.fetchCharactersCalledWithPage, 1)
        XCTAssertEqual(apiService.fetchCharactersCalledWithSearchQuery, query)
        XCTAssertEqual(sut.characters, [Character.preview])
    }
    
    @MainActor
    func testFetchFavouriteCharactersOnSearchQueryChange() async throws {
        // Given
        let query = "Rick"
        let expect = [expectation(description: "Characters fetched")]
        apiService.expect = expect
        repository.favouriteCharacterIds = [Character.preview.id]
        sut.showOnlyFavourites = true
        
        // When
        sut.searchQuery = query
        
        // Then
        await fulfillment(of: expect)
        
        XCTAssertFalse(apiService.fetchCharactersCalled)
        XCTAssertTrue(apiService.fetchCharacterIdCalled)
        XCTAssertTrue(repository.fetchFavouriteCharacterIdsCalled)
        XCTAssertEqual(sut.characters, [Character.preview])
    }
    
    @MainActor
    func testEnableFavouritesFilter() async throws {
        // Given
        let expect = [expectation(description: "Characters fetched")]
        apiService.expect = expect
        repository.favouriteCharacterIds = [Character.preview.id]
        sut.showOnlyFavourites = false
        
        // When
        sut.toggleFavouritesFilter()
        
        // Then
        XCTAssertTrue(sut.showOnlyFavourites)
        XCTAssertTrue(sut.isLoading)
        
        await fulfillment(of: expect)
        
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.didReachEnd)
        XCTAssertTrue(apiService.fetchCharacterIdCalled)
        XCTAssertFalse(apiService.fetchCharactersCalled)
        XCTAssertTrue(repository.fetchFavouriteCharacterIdsCalled)
        XCTAssertEqual(sut.characters, [Character.preview])
        XCTAssertNil(sut.errorMessage)
    }
    
    @MainActor
    func testDisableFavouritesFilter() async throws {
        // Given
        let expect = [expectation(description: "Characters fetched")]
        apiService.expect = expect
        repository.favouriteCharacterIds = [Character.preview.id]
        sut.showOnlyFavourites = true
        
        // When
        sut.toggleFavouritesFilter()
        
        // Then
        XCTAssertFalse(sut.showOnlyFavourites)
        XCTAssertFalse(sut.didReachEnd)
        XCTAssertTrue(sut.isLoading)
        
        await fulfillment(of: expect)
        
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.didReachEnd)
        XCTAssertTrue(apiService.fetchCharactersCalled)
        XCTAssertFalse(apiService.fetchCharacterIdCalled)
        XCTAssertFalse(repository.fetchFavouriteCharacterIdsCalled)
        XCTAssertEqual(sut.characters, [Character.preview])
        XCTAssertNil(sut.errorMessage)
    }
    
    @MainActor
    func testFetchFavouriteCharactersError() async throws {
        // Given
        let expect = [expectation(description: "Characters fetched")]
        apiService.error = APIError(message: "Error")
        apiService.expect = expect
        repository.favouriteCharacterIds = [Character.preview.id]
        sut.showOnlyFavourites = false
        
        // When
        sut.toggleFavouritesFilter()
        
        // Then
        XCTAssertTrue(sut.showOnlyFavourites)
        XCTAssertTrue(sut.isLoading)
        
        await fulfillment(of: expect)
        
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.didReachEnd)
        XCTAssertTrue(apiService.fetchCharacterIdCalled)
        XCTAssertFalse(apiService.fetchCharactersCalled)
        XCTAssertTrue(repository.fetchFavouriteCharacterIdsCalled)
        XCTAssertEqual(sut.characters, [])
        XCTAssertEqual(sut.errorMessage, "Error")
    }
}
