//
//  TagTests.swift
//  FeedbackAssistantTests
//
//  Created by Eng You Guan on 24/7/24.
//

import CoreData
import XCTest
@testable import FeedbackAssistant

final class TagTests: BaseTestCase {

    func testCreatingTagsAndIssues() {
        // Given
        let count = 10

        // When
        for _ in 0..<count {
            let tag = Tag(context: managedObjectContext)

            for _ in 0..<count {
                let issue = Issue(context: managedObjectContext)
                tag.addToIssues(issue)
            }
        }

        // Then
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()),
                       count,
                       "There should be \(count) tags.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()),
                       count * count,
                       "There should be \(count * count) issues.")

    }

    func testDeletingTagDoesNotDeleteIssues() throws {
        // Given
        dataController.createSampleData()
        let request = NSFetchRequest<Tag>(entityName: "Tag")
        let tags = try managedObjectContext.fetch(request)

        // When
        dataController.delete(tags[0])

        // Then
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 4, "Expected 4 tags after deleting 1.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 50, "Expected 50 issues after deleting a tag.")
    }

}
