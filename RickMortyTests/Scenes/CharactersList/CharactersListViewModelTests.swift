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

    override func setUp() async throws {
        apiService = RickMortyAPIServiceMock()
        sut = await CharactersListViewModel(apiService: apiService)
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
}
