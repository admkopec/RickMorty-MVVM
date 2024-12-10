//
//  EpisodeDetailsViewModel.swift
//  RickMorty
//
//  Created by Adam Kopeć on 10/12/2024.
//

import SwiftUI

@MainActor
class EpisodeDetailsViewModel: ObservableObject {
    private let episode: Episode
    
    // MARK: - State
    @Published var name: String = ""
    @Published var airDate: String = ""
    @Published var episodeCode: String = ""
    @Published var numberOfCharacters: Int = 0
    
    // MARK: - Display Logic
    
    func displayEpisode(episode: Episode) {
        name = episode.name
        airDate = episode.air_date
        episodeCode = episode.episode
        numberOfCharacters = episode.characters.count
    }
    
    // MARK: - Setup
    
    init(episode: Episode) {
        self.episode = episode
        displayEpisode(episode: episode)
    }
}
