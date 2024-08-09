//
//  DataController.swift
//  FeedbackAssistant
//
//  Created by Eng You Guan on 18/7/24.
//

import CoreData
import StoreKit
import SwiftUI
import WidgetKit

enum SortType: String {
    case dateCreated = "createdDate"
    case dateModified = "modifiedDate"
}

enum Status {
    case all, open, closed
}

/// An environemnt singleton responsible for managing our Core Data stack, including handling saving,
/// counting fetch requests, tracking orders and dealing with sample data
class DataController: ObservableObject {
    /// The lone CloudKit container used to store all our data.
    let container: NSPersistentCloudKitContainer
    var spotlightDelegate: NSCoreDataCoreSpotlightDelegate?

    @Published var selectedFilter: Filter? = Filter.all
    @Published var selectedIssue: Issue?
    @Published var filterText = ""
    @Published var filterTokens = [Tag]()

    @Published var filterEnabled = false
    @Published var filterPriority = -1
    @Published var filterStatus = Status.all
    @Published var sortType = SortType.dateCreated
    @Published var sortNewestFirst = true

    private var storeTask: Task<Void, Never>?
    private var saveTask: Task<Void, Error>?

    /// The UserDefaults suite where we're saving user data.
    let defaults: UserDefaults

    /// The StoreKit products we've loaded for the store
    @Published var products = [Product]()

    var suggestedFilterTokens: [Tag] {
        guard filterText.starts(with: "#") else {
            return []
        }
        let trimmedFilterText = String(filterText.dropFirst()).trimmingCharacters(in: .whitespaces)
        let request = Tag.fetchRequest()
        if trimmedFilterText.isEmpty == false {
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
        }
        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }

    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()

    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load Model file.")
        }
        return managedObjectModel
    }()

    /// Initializes a data controller, either in memory (for testing use such as previewing)
    /// or on permanent storage (for use in regular app runs.) Defaults to permanent storage.
    /// Loads managed object model only once
    /// - Parameter inMemory: Whether to store this data in temporary memory or not
    /// - Parameter defaults: The UserDefaults suite where user data should be stored.
    init(inMemory: Bool = false, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)

        storeTask = Task { await monitorTransactions() }

        // For testing and previewing purposes, we create a
        // temporary, in-memory database by writing to /dev/null
        // so our data is destroyed after teh app finishes running
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        } else {
            let groupID = "group.me.eng.yg.feedbackAssistant"
            if let url = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: groupID) {
                container.persistentStoreDescriptions.first?.url = url.appending(path: "Main.sqlite")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        // Make sure that we watch iCloud for all changes to make
        // absolutely sure we keep our local UI in sync when a
        // remote change happens.
        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )

        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
            forKey: NSPersistentHistoryTrackingKey
        )

        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: .main,
            using: remoteStoreChanged
        )

        container.loadPersistentStores { [weak self] _, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }

            if let description = self?.container.persistentStoreDescriptions.first {
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

                if let coordinator = self?.container.persistentStoreCoordinator {
                    self?.spotlightDelegate = NSCoreDataCoreSpotlightDelegate(
                        forStoreWith: description,
                        coordinator: coordinator
                    )
                    self?.spotlightDelegate?.startSpotlightIndexing()
                }
            }

            #if DEBUG
            if CommandLine.arguments.contains("enable-testing") {
                self?.deleteAll()
                UIView.setAnimationsEnabled(false)
            }
            #endif
        }
    }

    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }

    func createSampleData() {
        let viewContext = container.viewContext

        for tagCounter in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(tagCounter)"

            for issueCounter in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(tagCounter)-\(issueCounter)"
                issue.content = "Description goes here"
                issue.createdDate = .now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                tag.addToIssues(issue)
            }
        }
        try? viewContext.save()
    }

    /// Saves our Core Data context if there are changes
    func save() {
        saveTask?.cancel()
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    func queueSave() {
        saveTask?.cancel()
        saveTask = Task { @MainActor in
            // print("Queueing save")
            try await Task.sleep(for: .seconds(3))
            save()
            // print("Saved")
        }
    }

    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }

    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        // When performing a batch delete we need to make sure we read the result back
        // then merge all the changes from that result back into our live view context
        // so that the two stay in sync.
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }

    func deleteAll() {
        let allTags: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(allTags)
        let allIssues: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
        delete(allIssues)
        save()
    }

    func missingTags(from issue: Issue) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []
        let allTagsSet = Set(allTags)
        let difference = allTagsSet.symmetricDifference(issue.issueTags)
        return difference.sorted()
    }

    /// Runs a fetch request with various predicates that filter the user's issues based on
    /// tag, title, and content text, search tokens, priority, and completion status
    /// - Returns: An array of all matching issues
    func issuesForSelectedFilter() -> [Issue] {
        let filter = selectedFilter ?? .all
        var predicates = [NSPredicate]()
        if let tag = filter.tag {
            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
            predicates.append(tagPredicate)
        } else {
            let dataPredicate = NSPredicate(format: "modifiedDate > %@", filter.minModificationDate as NSDate)
            predicates.append(dataPredicate)
        }
        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)
        if trimmedFilterText.isEmpty == false {
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
            let contentPredicate = NSPredicate(format: "content CONTAINS[c] %@", trimmedFilterText)
            let combinedPredicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [
                    titlePredicate,
                    contentPredicate
                ])
            predicates.append(combinedPredicate)
        }
//        if filterTokens.isEmpty == false {
//            let tokenPredicate = NSPredicate(format: "ANY tags in %@", filterTokens)
//            predicates.append(tokenPredicate)
//        }
        if filterTokens.isEmpty == false {
            for filterToken in filterTokens {
                let tokenPredicate = NSPredicate(format: "tags CONTAINS %@", filterToken)
                predicates.append(tokenPredicate)
            }
        }
        if filterEnabled {
            if filterPriority >= 0 {
                let priorityFilter = NSPredicate(format: "priority = %d", filterPriority)
                predicates.append(priorityFilter)
            }
            if filterStatus != .all {
                let lookforClosed = filterStatus == .closed
                let statusFilter = NSPredicate(format: "completed == %@", lookforClosed as NSNumber)
                predicates.append(statusFilter)
            }
        }
        let request = Issue.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: !sortNewestFirst)]
        let allIssues = (try? container.viewContext.fetch(request)) ?? []
        return allIssues
    }

    func newTag() -> Bool {
        var shouldCreate = fullVersionUnlocked
        if shouldCreate == false {
            shouldCreate = count(for: Tag.fetchRequest()) < 3
        }
        guard shouldCreate else {
            return false
        }

        let tag = Tag(context: container.viewContext)
        tag.id = UUID()
        tag.name = NSLocalizedString("New tag", comment: "Create a new tag")
        save()
        return true
    }

    func newIssue() {
        let issue = Issue(context: container.viewContext)
        issue.title = NSLocalizedString("New issue", comment: "Create a new issue")
        issue.createdDate = .now
        issue.priority = 1

        // If we are currently browsing a user-created tag, immediately
        // add this new issue to the tag otherwise it won't appear in
        // the list of issues they see.
        if let tag = selectedFilter?.tag {
            issue.addToTags(tag)
        }
        save()
        selectedIssue = issue
    }

    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }

    // get issue Object based on string
    func issue(with uniqueIdentifier: String) -> Issue? {
        guard let url = URL(string: uniqueIdentifier) else {
            return nil
        }
        // get Object ID based on string
        guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url)
        else {
            return nil
        }
        return try? container.viewContext.existingObject(with: id) as? Issue
    }

    func fetchRequestForTopIssues(count: Int) -> NSFetchRequest<Issue> {
        let request = Issue.fetchRequest()
        request.predicate = NSPredicate(format: "completed = false")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Issue.priority, ascending: false)]
        request.fetchLimit = count
        return request
    }

    func results<T: NSManagedObject>(for fetchRequest: NSFetchRequest<T>) -> [T] {
        return (try? container.viewContext.fetch(fetchRequest)) ?? []
    }
}
