//
//  PerformanceTests.swift
//  FeedbackAssistantTests
//
//  Created by Eng You Guan on 25/7/24.
//

import XCTest
@testable import FeedbackAssistant

final class PerformanceTests: BaseTestCase {
    func testAwardCalculationPerformance() {
        for _ in 1...100{
            dataController.createSampleData()
        }
        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        XCTAssertEqual(awards.count, 500, "This checks the awards count is constant")
        measure {
            _ = awards.filter(dataController.hasEarned)
        }
    }

}
