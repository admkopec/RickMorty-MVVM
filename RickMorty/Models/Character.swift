//
//  Character.swift
//  RickMorty
//
//  Created by Adam Kopeć on 08/06/2024.
//

import Foundation

struct Character: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let status: String
    let gender: String
    let origin: NameURLTuple
    let location: NameURLTuple
    let image: URL
    let episode: [URL]
    
    static func == (lhs: Character, rhs: Character) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct NameURLTuple: Codable {
    let name: String
}

#if DEBUG
extension Character {
    static var preview: Character {
        Character(id: 1, name: "Rick", status: "Alive", gender: "Male", origin: NameURLTuple(name: "Earth (C-137)"), location: NameURLTuple(name: "Earth (Replacement Dimension)"), image: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")!, episode: [URL(string: "https://rickandmortyapi.com/api/episode/1")!])
    }
}
#endif
