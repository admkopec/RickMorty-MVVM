//
//  EpisodeDetailsViewModelTests.swift
//  RickMortyTests
//
//  Created by Adam Kopeć on 10/12/2024.
//

import XCTest
@testable import RickMorty

final class EpisodeDetailsViewModelTests: XCTestCase {
    
    private var sut: EpisodeDetailsViewModel!
    private var episode: Episode!
    
    override func setUp() async throws {
        episode = Episode.preview
        sut = await EpisodeDetailsViewModel(episode: episode)
    }
    
    @MainActor
    func testDisplayEpisode() throws {
        // Given
        let episode = Episode(id: 1, name: "Pilot",
                              air_date: "December 2, 2013", episode: "S01E01",
                              characters: [URL(string: "https://example.com/")!])
        
        // When
        sut.displayEpisode(episode: episode)
        
        // Then
        XCTAssertEqual(sut.name, episode.name)
        XCTAssertEqual(sut.airDate, episode.air_date)
        XCTAssertEqual(sut.episodeCode, episode.episode)
        XCTAssertEqual(sut.numberOfCharacters, episode.characters.count)
    }
    
    @MainActor
    func testDisplayEpisodeOnLoad() throws {
        XCTAssertEqual(sut.name, episode.name)
        XCTAssertEqual(sut.airDate, episode.air_date)
        XCTAssertEqual(sut.episodeCode, episode.episode)
        XCTAssertEqual(sut.numberOfCharacters, episode.characters.count)
    }
}
