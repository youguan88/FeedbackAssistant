//
//  ExtensionTests.swift
//  FeedbackAssistantTests
//
//  Created by Eng You Guan on 24/7/24.
//

import CoreData
import XCTest
@testable import FeedbackAssistant

final class ExtensionTests: BaseTestCase {
    func testIssueTitleUnwrap() {
        // Given
        let issue = Issue(context: managedObjectContext)

        // When
        issue.title = "Example issue"
        // Then
        XCTAssertEqual(issue.issueTitle, "Example issue", "Changing title should also change issueTitle")

        // When
        issue.issueTitle = "Updated issue"
        // Then
        XCTAssertEqual(issue.title, "Updated issue", "Changing issueTitle should also change title.")
    }

    func testIssueContentUnwrap() {
        // Given
        let issue = Issue(context: managedObjectContext)

        // When
        issue.content = "Example issue"
        // Then
        XCTAssertEqual(issue.issueContent, "Example issue", "Changing content should also change issueContent")

        // When
        issue.issueContent = "Updated issue"
        // Then
        XCTAssertEqual(issue.content, "Updated issue", "Changing issueContent should also change content.")
    }

    func testIssueCreatedDateUnwrap() {
        // Given
        let issue = Issue(context: managedObjectContext)
        let testDate = Date.now
        // When
        issue.createdDate = testDate
        // Then
        XCTAssertEqual(issue.issueCreatedDate, testDate, "Changing createdDate should also change issueCreatedDate")
    }

    func testIssueTagsUnwrap() {
        // Given
        let tag = Tag(context: managedObjectContext)
        let issue = Issue(context: managedObjectContext)
        XCTAssertEqual(issue.issueTags.count, 0, "A new issue should have no tags.")
        // When
        issue.addToTags(tag)
        // Then
        XCTAssertEqual(issue.issueTags.count, 1, "Adding 1 tag to an issue should result in issueTags having 1 tag")
    }

    func testIssueTagsList() {
        // Given
        let tag = Tag(context: managedObjectContext)
        let issue = Issue(context: managedObjectContext)
        // When
        tag.name = "My Tag"
        issue.addToTags(tag)
        // Then
        XCTAssertEqual(issue.issueTagsList, "My Tag", "Adding 1 tag to an issue should result in issueTags be My Tag")
    }

    func testIssueSortingIsStable() {
        // Given
        let issue1 = Issue(context: managedObjectContext)
        issue1.title = "B Issue"
        issue1.createdDate = .now

        let issue2 = Issue(context: managedObjectContext)
        issue2.title = "B Issue"
        issue2.createdDate = .now.addingTimeInterval(1)

        let issue3 = Issue(context: managedObjectContext)
        issue3.title = "A Issue"
        issue3.createdDate = .now.addingTimeInterval(100)

        let allIssues = [issue1, issue2, issue3]

        // When
        let sorted = allIssues.sorted()
        // Then
        XCTAssertEqual([issue3, issue1, issue2], sorted, "Sorting issue arrays should use name then creation date")
    }

    func testTagIDUnwrap() {
        // Given
        let tag = Tag(context: managedObjectContext)
        // When
        tag.id = UUID()
        // Then
        XCTAssertEqual(tag.id, tag.tagID, "Changing id should also change tagID.")
    }

    func testTagNameUnwrap() {
        // Given
        let tag = Tag(context: managedObjectContext)
        // When
        tag.name = "Example Tag"
        // Then
        XCTAssertEqual(tag.tagName, "Example Tag", "Changing name should also change tagName.")
    }

    func testTagActiveIssues() {
        // Given
        let tag = Tag(context: managedObjectContext)
        let issue = Issue(context: managedObjectContext)
        XCTAssertEqual(tag.tagActiveIssues.count, 0, "A new tag should have 0 active issues")

        // When
        tag.addToIssues(issue)
        // Then
        XCTAssertEqual(tag.tagActiveIssues.count, 1, "A new tag with 1 new issue should have 1 active issue.")

        // When
        issue.completed = true
        // Then
        XCTAssertEqual(tag.tagActiveIssues.count, 0, "A new tag with 1 completed issue should have 0 active issues.")
    }

    func testTagSortingIsStable() {
        // Given
        let tag1 = Tag(context: managedObjectContext)
        tag1.name = "B Tag"
        tag1.id = UUID()

        let tag2 = Tag(context: managedObjectContext)
        tag2.name = "B Tag"
        tag2.id = UUID(uuidString: "FFFFFFFF-B00A-4915-B023-F58A8251BE74")

        let tag3 = Tag(context: managedObjectContext)
        tag3.name = "A Tag"
        tag3.id = UUID()

        let allTags = [tag1, tag2, tag3]

        // When
        let sortedTags = allTags.sorted()
        // Then
        XCTAssertEqual([tag3, tag1, tag2], sortedTags, "Sorting tag arrays should use name then UUID string")
    }

    func testBundleDecodingAwards() {
        // Given
        let awards = Bundle.main.decode("Awards.json", as: [Award].self)
        // Then
        XCTAssertFalse(awards.isEmpty, "Awards.json should decode to a non-empty array.")
    }

    func testDecodingString() {
        // Given
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode("DecodableString.json", as: String.self)
        // Then
        XCTAssertEqual(data, "This is a string", "The string must match DecodableString.json")
    }

    func testDecodingDictionary() {
        // Given
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode("DecodableDictionary.json", as: [String: Int].self)
        // Then
        XCTAssertEqual(data.count, 3, "There should be three items")
        XCTAssertEqual(data["One"], 1, "The dictionary should contain the value 1 for the key One.")
    }
}
