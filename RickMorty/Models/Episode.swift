//
//  Episode.swift
//  RickMorty
//
//  Created by Adam Kopeć on 08/06/2024.
//

import Foundation

struct Episode: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let air_date: String
    let episode: String
    let characters: [URL]
    
    static func == (lhs: Episode, rhs: Episode) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#if DEBUG
extension Episode {
    static var preview: Episode {
        Episode(id: 1, name: "Pilot", air_date: "December 2, 2013", episode: "S01E01", characters: [URL(string: "https://rickandmortyapi.com/api/character/1")!])
    }
}
#endif
