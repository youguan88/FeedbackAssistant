//
//  AwardsTest.swift
//  FeedbackAssistantTests
//
//  Created by Eng You Guan on 24/7/24.
//

import CoreData
import XCTest
@testable import FeedbackAssistant

final class AwardsTest: BaseTestCase {
    // Given
    let awards = Award.allAwards

    func testAwardIDMatchesName() {
        // Then
        for award in awards {
            XCTAssertEqual(award.id, award.name, "Award ID should always match its name.")
        }
    }

    func testNewUserHasUnlockedNoAwards() {
        // Then
        for award in awards {
            XCTAssertFalse(dataController.hasEarned(award: award), "New users should have no earned award.")
        }
    }

    func testCreatingIssuesUnlockAwardsO() {
        // Given
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for(count, value) in values.enumerated() {
            var issues = [Issue]()

            // When
            for _ in 0..<value {
                let issue = Issue(context: managedObjectContext)
                issues.append(issue)
            }

            let matches = awards.filter { award in
                award.criterion == "issues" && dataController.hasEarned(award: award)
            }
            // Then
            XCTAssertEqual(matches.count, count + 1, "Adding \(value) issues should unlock \(count + 1) awards")
            dataController.deleteAll()
        }
    }

    func testClosingIssuesUnlockAwardsO() {
        // Given
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for(count, value) in values.enumerated() {
            var issues = [Issue]()

            // When
            for _ in 0..<value {
                let issue = Issue(context: managedObjectContext)
                issue.completed = true
                issues.append(issue)
            }

            let matches = awards.filter { award in
                award.criterion == "closed" && dataController.hasEarned(award: award)
            }

            // Then
            XCTAssertEqual(matches.count, count + 1, "Completing \(value) issues should unlock \(count + 1) awards")
            dataController.deleteAll()
        }
    }
}
