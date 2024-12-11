//
//  RickMortyUITests.swift
//  RickMortyUITests
//
//  Created by Adam Kopeć on 08/06/2024.
//

import XCTest

final class RickMortyUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testOnboarding() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssert(app.staticTexts["Welcome to Rick & Morty"].exists)
        XCTAssert(app.buttons["Get Started"].exists)
    }
    
    @MainActor
    func testCharactersList() async throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Get Started"].tap()
        try await Task.sleep(for: .milliseconds(200))
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssert(app.staticTexts["Characters"].exists)
        XCTAssert(app.searchFields["Search by name"].exists)
        XCTAssert(app.buttons["Rick Sanchez"].exists)
    }
    
    @MainActor
    func testCharactersListSearch() async throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Get Started"].tap()
        try await Task.sleep(for: .milliseconds(200))
        
        app.searchFields["Search by name"].tap()
        app.searchFields["Search by name"].typeText("Rick")
        try await Task.sleep(for: .milliseconds(800))
        
        // Verify that the search results are displayed
        XCTAssert(app.buttons["Rick Sanchez"].exists)
        XCTAssert(app.buttons["Rick Sanchez"].isHittable)
    }
    
    @MainActor
    func testCharactersListSearchNoMatch() async throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Get Started"].tap()
        try await Task.sleep(for: .milliseconds(200))
        
        app.searchFields["Search by name"].tap()
        app.searchFields["Search by name"].typeText("Abcdefghijkl")
        try await Task.sleep(for: .milliseconds(800))
        
        XCTAssert(app.staticTexts["Could not load data!"].exists)
    }
    
    @MainActor
    func testCharacterDetails() async throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Get Started"].tap()
        try await Task.sleep(for: .milliseconds(200))
        app.buttons["Rick Sanchez"].tap()
        
        // Verify that the character details are displayed
        XCTAssert(app.buttons["Toggle Favourite"].exists)
        
        XCTAssert(app.staticTexts["Rick Sanchez"].exists)
        
        XCTAssert(app.staticTexts["Info"].exists)
        XCTAssert(app.staticTexts["Status"].exists)
        XCTAssert(app.staticTexts["Alive"].exists)
        XCTAssert(app.staticTexts["Gender"].exists)
        XCTAssert(app.staticTexts["Male"].exists)
        XCTAssert(app.staticTexts["Origin"].exists)
        XCTAssert(app.staticTexts["Earth (C-137)"].exists)
        XCTAssert(app.staticTexts["Location"].exists)
        XCTAssert(app.staticTexts["Citadel of Ricks"].exists)
        
        XCTAssert(app.staticTexts["Episodes"].exists)
        XCTAssert(app.buttons["Episode S01E01"].exists)
    }
    
    @MainActor
    func testEpisodeDetails() async throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Get Started"].tap()
        try await Task.sleep(for: .milliseconds(200))
        app.buttons["Rick Sanchez"].tap()
        try await Task.sleep(for: .milliseconds(200))
        app.buttons["Episode S01E01"].tap()
        
        // Verify that the episode details are displayed
        XCTAssert(app.staticTexts["Pilot"].exists)
        XCTAssert(app.staticTexts["S01E01"].exists)
        XCTAssert(app.staticTexts["First aired"].exists)
        XCTAssert(app.staticTexts["December 2, 2013"].exists)
        XCTAssert(app.staticTexts["Number of characters"].exists)
        XCTAssert(app.staticTexts["19"].exists)
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
