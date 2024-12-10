//
//  RickMortyApp.swift
//  RickMorty
//
//  Created by Adam Kopeć on 10/12/2024.
//

import SwiftUI

@main
struct RickMortyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
