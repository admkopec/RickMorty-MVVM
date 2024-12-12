//
//  RickMortyAPIServiceTests.swift
//  RickMortyTests
//
//  Created by Adam Kopeć on 10/12/2024.
//

import XCTest
@testable import RickMorty

final class RickMortyAPIServiceTests: XCTestCase {
    
    private var sut: RickMortyAPIServiceImpl!

    override func setUpWithError() throws {
        sut = RickMortyAPIServiceImpl(session: .mock)
    }

    override func tearDownWithError() throws {
        MockAPI.requestHandler = nil
    }

    func testFetchCharacters() async throws {
        // Given
        let page = 1
        let query = "Rick"
        let character = Character.preview
        MockAPI.requestHandler = { request in
            let urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
            let queryItems = urlComponents.queryItems!
            let pageQueryItem = queryItems.first { $0.name == "page" }!
            let nameQueryItem = queryItems.first { $0.name == "name" }!
            
            XCTAssertEqual(pageQueryItem.value, "\(page)")
            XCTAssertEqual(nameQueryItem.value, query)
            
            let apiResponse = APIResponse(info: .init(count: 1, pages: 1, next: nil, prev: nil), results: [character])
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])!
            return (response, try! JSONEncoder().encode(apiResponse))
            
        }
        
        // When
        let (characters, moreAvailable) = try await sut.fetchCharacters(page: page, with: query)
        
        // Then
        XCTAssertEqual(characters.count, 1)
        XCTAssertEqual(characters.first, character)
        XCTAssertFalse(moreAvailable)
    }
    
    func testFetchCharactersMultiplePages() async throws {
        // Given
        let page = 1
        let query = "Rick"
        let character = Character.preview
        MockAPI.requestHandler = { request in
            let urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
            let queryItems = urlComponents.queryItems!
            let pageQueryItem = queryItems.first { $0.name == "page" }!
            let nameQueryItem = queryItems.first { $0.name == "name" }!
            
            XCTAssertEqual(pageQueryItem.value, "\(page)")
            XCTAssertEqual(nameQueryItem.value, query)
            
            let apiResponse = APIResponse(info: .init(count: 1, pages: 2, next: URL(string: "https://example.com/")!, prev: nil), results: [character])
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])!
            return (response, try! JSONEncoder().encode(apiResponse))
            
        }
        
        // When
        let (characters, moreAvailable) = try await sut.fetchCharacters(page: page, with: query)
        
        // Then
        XCTAssertEqual(characters.count, 1)
        XCTAssertEqual(characters.first, character)
        XCTAssertTrue(moreAvailable)
    }
    
    func testFetchCharactersAPIError() async throws {
        // Given
        let page = 1
        let query = "Rick"
        let apiError = APIErrorResponse(error: "Not found")
        MockAPI.requestHandler = { request in
            let urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
            let queryItems = urlComponents.queryItems!
            let pageQueryItem = queryItems.first { $0.name == "page" }!
            let nameQueryItem = queryItems.first { $0.name == "name" }!
            
            XCTAssertEqual(pageQueryItem.value, "\(page)")
            XCTAssertEqual(nameQueryItem.value, query)
            
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])!
            return (response, try! JSONEncoder().encode(apiError))
        }
        
        // When
        do {
            _ = try await sut.fetchCharacters(page: page, with: query)
            XCTFail("Expected error")
        } catch {
            // Then
            XCTAssertTrue(error is APIError)
            XCTAssertEqual((error as! APIError).message, APIError(message: apiError.error).message)
        }
    }
    
    func testFetchCharacterById() async throws {
        // Given
        let id = 1
        let character = Character.preview
        MockAPI.requestHandler = { request in
            XCTAssert(request.url?.absoluteString.hasSuffix("character/\(id)") == true)
            
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])!
            return (response, try! JSONEncoder().encode(character))
        }

        // When
        let fetchedCharacter = try await sut.fetchCharacter(id: id)
        
        // Then
        XCTAssertEqual(fetchedCharacter, character)
    }
    
    func testFetchCharacterByIdAPIError() async throws {
        // Given
        let id = 1
        let apiError = APIErrorResponse(error: "Not found")
        MockAPI.requestHandler = { request in
            XCTAssert(request.url?.absoluteString.hasSuffix("character/\(id)") == true)

            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])!
            return (response, try! JSONEncoder().encode(apiError))
        }
        
        // When
        do {
            _ = try await sut.fetchCharacter(id: id)
            XCTFail("Expected error")
        } catch {
            // Then
            XCTAssertTrue(error is APIError)
            XCTAssertEqual((error as! APIError).message, APIError(message: apiError.error).message)
        }
    }

    func testFetchEpisodeById() async throws {
        // Given
        let id = 1
        let episode = Episode.preview
        MockAPI.requestHandler = { request in
            XCTAssert(request.url?.absoluteString.hasSuffix("episode/\(id)") == true)
            
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])!
            return (response, try! JSONEncoder().encode(episode))
        }
        
        // When
        let fetchedEpisode = try await sut.fetchEpisode(id: id)
        
        // Then
        XCTAssertEqual(fetchedEpisode, episode)
    }
    
    func testFetchEpisodeByURL() async throws {
        // Given
        let url = URL(string: "https://example.com/")!
        let episode = Episode.preview
        MockAPI.requestHandler = { request in
            XCTAssertEqual(request.url, url)
            
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])!
            return (response, try! JSONEncoder().encode(episode))
        }
        
        // When
        let fetchedEpisode = try await sut.fetchEpisode(url: url)
        
        // Then
        XCTAssertEqual(fetchedEpisode, episode)
    }
    
    func testFetchEpisodeAPIError() async throws {
        // Given
        let id = 1
        let apiError = APIErrorResponse(error: "Not found")
        MockAPI.requestHandler = { request in
            XCTAssert(request.url?.absoluteString.hasSuffix("episode/\(id)") == true)
            
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])!
            return (response, try! JSONEncoder().encode(apiError))
        }
        
        // When
        do {
            _ = try await sut.fetchEpisode(id: id)
            XCTFail("Expected error")
        } catch {
            // Then
            XCTAssertTrue(error is APIError)
            XCTAssertEqual((error as! APIError).message, APIError(message: apiError.error).message)
        }
    }
}
