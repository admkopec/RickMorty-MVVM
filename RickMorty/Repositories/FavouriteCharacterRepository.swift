//
//  FavouriteCharacterRepository.swift
//  RickMorty
//
//  Created by Adam Kopeć on 08/06/2024.
//

import CoreData
import Combine

protocol FavouriteCharacterRepository {
    /// Fetches all favourite character IDs from CoreData database
    /// - Throws: Error if fetching from CoreData fails
    /// - Returns: Array of favourite character IDs
    func fetchFavouriteCharacterIds() async throws -> [Int]
    
    /// Fetches if character with given ID is marked as favourite in CoreData database
    /// - Parameter characterId: ID of character to check
    /// - Throws: Error if fetching from CoreData fails
    /// - Returns: `true` if character is favourite, `false` otherwise
    func fetchIsFavourite(for characterId: Int) async throws -> Bool
    
    /// Adds character with given ID to favourites in CoreData database
    /// - Parameter characterId: ID of character to add to favourites
    /// - Throws: Error if saving to CoreData fails
    func addFavourite(for characterId: Int) async throws
    
    /// Removes character with given ID from favourites in CoreData database
    /// - Parameter characterId: ID of character to remove from favourites
    /// - Throws: Error if saving to CoreData fails
    func removeFavourite(for characterId: Int) async throws
    
    /// Changes publisher to notify about changes in favourite characters
    /// - Returns: Publisher that emits changes in favourite characters
    func favouriteCharactersPublisher() -> AnyPublisher<Notification, Never>
}

class FavouriteCharacterRepositoryImpl: FavouriteCharacterRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    func fetchFavouriteCharacterIds() async throws -> [Int] {
        let request = FavouriteCharacter.fetchRequest()
        
        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    let result = try self.context.fetch(request)
                    continuation.resume(returning: result.map({ Int($0.characterId) }))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func fetchIsFavourite(for characterId: Int) async throws -> Bool {
        let request = FavouriteCharacter.fetchRequest()
        request.predicate = NSPredicate(format: "characterId == %d", characterId)
        
        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    let result = try self.context.fetch(request)
                    continuation.resume(returning: !result.isEmpty)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func addFavourite(for characterId: Int) async throws {
        let favouriteCharacter = FavouriteCharacter(context: context)
        favouriteCharacter.characterId = Int32(characterId)
        
        try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    try self.context.save()
                    continuation.resume()
                } catch {
                    self.context.rollback()
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func removeFavourite(for characterId: Int) async throws {
        let request = FavouriteCharacter.fetchRequest()
        request.predicate = NSPredicate(format: "characterId == %d", characterId)
        
        try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    let result = try self.context.fetch(request)
                    
                    result.forEach { favouriteCharacter in
                        self.context.delete(favouriteCharacter)
                    }
                    
                    try self.context.save()
                    
                    continuation.resume()
                } catch {
                    self.context.rollback()
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func favouriteCharactersPublisher() -> AnyPublisher<Notification, Never> {
        return NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange).eraseToAnyPublisher()
    }
}
