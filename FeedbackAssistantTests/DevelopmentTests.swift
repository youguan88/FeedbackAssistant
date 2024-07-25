//
//  DevelopmentTests.swift
//  FeedbackAssistantTests
//
//  Created by Eng You Guan on 24/7/24.
//

import CoreData
import XCTest
@testable import FeedbackAssistant

final class DevelopmentTests: BaseTestCase {
    func testSampleDataCreationWorks() {
        // Given
        dataController.createSampleData()

        // Then
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 5, "There should be 5 sample tags.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 50, "There should be 5 sample issues.")
    }

    func testDeleteAllClearsEverything() {
        // Given
        dataController.createSampleData()
        // When
        dataController.deleteAll()
        // Then
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 0, "delete() should leave 0 sample tags.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 0, "deleteAll() should leave 0 sample issues.")
    }

    func testExampleTagHasNoIssues() {
        // Given
        let tag = Tag.example
        // Then
        XCTAssertEqual(tag.issues?.count, 0, "The example tag should have 0 issues.")
    }

    func testExampleIssueHighPriority() {
        // Given
        let issue = Issue.example
        // Then
        XCTAssertEqual(issue.priority, 2, "The example issue should be high priority")
    }
}
