//
//  AssetTests.swift
//  FeedbackAssistantTests
//
//  Created by Eng You Guan on 24/7/24.
//

import XCTest
@testable import FeedbackAssistant

final class AssetTests: XCTestCase {
    func testColorsExist() {
        // Given
        let allColors = ["Dark Blue", "Dark Gray", "Gold", "Gray", "Green",
                         "Light Blue", "Midnight", "Orange", "Pink", "Purple", "Red", "Teal"]
        for color in allColors {
            // Then
            XCTAssertNotNil(UIColor(named: color), "Failed to load color '\(color)' from asset catalog.")
        }
    }

    func testAwardsLoadCorrectly() {
        XCTAssertTrue(Award.allAwards.isEmpty == false, "Failed to load awards from JSON.")
    }
}
