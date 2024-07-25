//
//  FeedbackAssistantTests.swift
//  FeedbackAssistantTests
//
//  Created by Eng You Guan on 24/7/24.
//

import CoreData
import XCTest
@testable import FeedbackAssistant

class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
