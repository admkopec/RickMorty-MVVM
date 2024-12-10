//
//  Async.swift
//  RickMorty
//
//  Created by Adam Kopeć on 09/06/2024.
//

import Foundation

extension Sequence {
    func asyncMap<T>(_ transform: @escaping (Element) async throws -> T) async rethrows -> [T] {
        return try await withThrowingTaskGroup(of: T.self) { group in
            var transformedElements = [T]()
            
            for element in self {
                group.addTask {
                    return try await transform(element)
                }
            }
            
            for try await transformedElement in group {
                transformedElements.append(transformedElement)
            }
            
            return transformedElements
        }
    }
}
