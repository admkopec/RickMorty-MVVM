# Rick & Morty
A sample iOS application targeting iOS 16 written in SwiftUI using MVVM architecture and following iOS development best practices.
The application uses the [The Rick and Morty API](https://rickandmortyapi.com/documentation) to display list of characters and basic information about them.
The application aims to be modular following Clean Architecture guidelines and implementing repository patterns and separate servies classes for more advanced application logic.

## Features
- Infinite scroll pagination and `LazyVStack` for minimising the memory footprint of the application.
- `AsyncImage` for loading thumbnails only when needed
- CoreData storage for keeping track of "Favourite" characters
- `.searchable()` modifier for character searching

## Build & Run
### Requirements:
- Xcode 15.0 or later

To build the project open `RickMorty.xcodeproj` and run the RickMorty target on a simulator or a physical device.
