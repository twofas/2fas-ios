//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2023 Two Factor Authentication Service, Inc.
//  Contributed by Zbigniew Cisiński. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <https://www.gnu.org/licenses/>
//

import XCTest
import CoreData
@testable import Common
@testable import Storage

let twoFASStoreName = "TwoFAS"
let twoFASModelBundle = Bundle(for: Storage.self)

/// Creates a store with the given version of the TwoFAS model (`TwoFAS.momd/<version>.mom`).
func makeTwoFASStore(version: String, at url: URL, sectionCount: Int) throws {
    let modelURL = try XCTUnwrap(
        twoFASModelBundle.url(forResource: version, withExtension: "mom", subdirectory: "TwoFAS.momd")
    )
    let model = try XCTUnwrap(NSManagedObjectModel(contentsOf: modelURL))
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    let store = try coordinator.addPersistentStore(
        ofType: NSSQLiteStoreType,
        configurationName: nil,
        at: url,
        options: nil
    )
    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    context.persistentStoreCoordinator = coordinator
    try context.performAndWait {
        for _ in 0..<sectionCount {
            insertTestSection(into: context)
        }
        try context.save()
    }
    try coordinator.remove(store)
}

func insertTestSection(into context: NSManagedObjectContext) {
    let section = NSEntityDescription.insertNewObject(forEntityName: "SectionEntity", into: context)
    section.setValue(UUID(), forKey: "sectionID")
    // The current model keeps the title sealed – the bytes only have to be there, these tests don't open them
    if section.entity.attributesByName["title"] != nil {
        section.setValue("Section", forKey: "title")
    } else {
        section.setValue(Data("Section".utf8), forKey: "encryptedContent")
    }
    section.setValue(Date(), forKey: "creationDate")
    section.setValue(0, forKey: "order")
    section.setValue(false, forKey: "isCollapsed")
}

func countSections(in context: NSManagedObjectContext) throws -> Int {
    try context.performAndWait {
        try context.count(for: NSFetchRequest<NSFetchRequestResult>(entityName: "SectionEntity"))
    }
}

func storeDirectoryContents(_ directory: URL) throws -> [String] {
    try FileManager.default.contentsOfDirectory(atPath: directory.path).sorted()
}

final class CoreDataStackTests: XCTestCase {
    private var directory: URL!

    override func setUp() {
        super.setUp()
        directory = makeTemporaryDirectory()
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: directory)
        directory = nil
        super.tearDown()
    }

    private func makeStack(
        storeKind: CoreDataStack.StoreKind = .file,
        retainsViewContextObjects: Bool = false,
        configureContext: ((NSManagedObjectContext) -> Void)? = nil
    ) -> CoreDataStack {
        CoreDataStack(
            readOnly: false,
            name: twoFASStoreName,
            bundle: twoFASModelBundle,
            storeDirectory: directory,
            storeKind: storeKind,
            retainsViewContextObjects: retainsViewContextObjects,
            configureContext: configureContext
        )
    }

    private func storeFileURL(_ suffix: String) -> URL {
        directory.appendingPathComponent("\(twoFASStoreName)\(suffix)")
    }

    private func isStoreCompatible() -> Bool {
        CoreDataStack.isStoreCompatible(name: twoFASStoreName, bundle: twoFASModelBundle, directory: directory)
    }

    func testFileStoreHasExplicitProtection() {
        let description = makeStack().storeDescription

        XCTAssertEqual(description.type, NSSQLiteStoreType)
        XCTAssertEqual(description.url, CoreDataStack.storeURL(name: twoFASStoreName, directory: directory))
        XCTAssertEqual(
            description.options[NSPersistentStoreFileProtectionKey] as? FileProtectionType,
            .completeUntilFirstUserAuthentication
        )
    }

    func testStoreURLDefaultsToAppGroupContainer() throws {
        let container = try XCTUnwrap(
            FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Config.groupIdentifier)
        )
        XCTAssertEqual(
            CoreDataStack.storeURL(name: twoFASStoreName),
            container.appendingPathComponent("TwoFAS.sqlite")
        )
        XCTAssertEqual(
            CoreDataStack.storeURL(name: twoFASStoreName, directory: directory),
            storeFileURL(".sqlite")
        )
    }

    func testConfigureContextAppliedToAllContexts() throws {
        let lock = NSLock()
        var configured: [NSManagedObjectContext] = []
        let stack = makeStack { context in
            lock.lock()
            configured.append(context)
            lock.unlock()
        }

        let viewContext = stack.context
        let background = stack.createBackgroundContext()
        var performedAndWaited: NSManagedObjectContext?
        stack.performAndWaitInBackground { performedAndWaited = $0 }
        let performed = expectation(description: "performInBackground")
        var performedContext: NSManagedObjectContext?
        stack.performInBackground {
            performedContext = $0
            performed.fulfill()
        }
        wait(for: [performed], timeout: 5)

        let expected = [viewContext, background, try XCTUnwrap(performedAndWaited), try XCTUnwrap(performedContext)]
        lock.lock()
        let snapshot = configured
        lock.unlock()
        XCTAssertEqual(snapshot.count, 4)
        XCTAssertEqual(Set(snapshot.map(ObjectIdentifier.init)), Set(expected.map(ObjectIdentifier.init)))
    }

    func testRetainsViewContextObjects() {
        XCTAssertTrue(makeStack(retainsViewContextObjects: true).context.retainsRegisteredObjects)
        XCTAssertFalse(makeStack(storeKind: .inMemory).context.retainsRegisteredObjects)
    }

    func testInMemoryStoreCreatesNoFiles() throws {
        let stack = makeStack(storeKind: .inMemory)
        XCTAssertEqual(stack.storeDescription.type, NSInMemoryStoreType)

        insertTestSection(into: stack.context)
        stack.save()

        XCTAssertEqual(try countSections(in: stack.context), 1)
        XCTAssertFalse(CoreDataStack.storeFilesExist(name: twoFASStoreName, directory: directory))
        XCTAssertEqual(try storeDirectoryContents(directory), [])
    }

    func testDestroyStoreFilesRemovesSidecars() throws {
        let suffixes = [
            ".sqlite", ".sqlite-wal", ".sqlite-shm",
            ".sqlite.premigration", ".sqlite-wal.premigration", ".sqlite-shm.premigration", ".sqlite.swapped"
        ]
        for suffix in suffixes {
            XCTAssertTrue(FileManager.default.createFile(atPath: storeFileURL(suffix).path, contents: Data([1])))
        }
        let otherStore = directory.appendingPathComponent("Sync.sqlite")
        XCTAssertTrue(FileManager.default.createFile(atPath: otherStore.path, contents: Data([1])))
        XCTAssertTrue(CoreDataStack.storeFilesExist(name: twoFASStoreName, directory: directory))

        CoreDataStack.destroyStoreFiles(name: twoFASStoreName, directory: directory)

        XCTAssertEqual(try storeDirectoryContents(directory), ["Sync.sqlite"])
        XCTAssertFalse(CoreDataStack.storeFilesExist(name: twoFASStoreName, directory: directory))
        // Missing files are ignored
        CoreDataStack.destroyStoreFiles(name: twoFASStoreName, directory: directory)
        XCTAssertEqual(try storeDirectoryContents(directory), ["Sync.sqlite"])
    }

    func testStoreFilesExistForPremigrationStoreOnly() {
        XCTAssertFalse(CoreDataStack.storeFilesExist(name: twoFASStoreName, directory: directory))
        FileManager.default.createFile(atPath: storeFileURL(".sqlite.premigration").path, contents: Data([1]))
        XCTAssertTrue(CoreDataStack.storeFilesExist(name: twoFASStoreName, directory: directory))
    }

    func testDestroyAndRecreateStoreLeavesEmptyStore() throws {
        for storeKind in [CoreDataStack.StoreKind.file, .inMemory] {
            let stack = makeStack(storeKind: storeKind)
            insertTestSection(into: stack.context)
            stack.save()
            XCTAssertEqual(try countSections(in: stack.context), 1, "\(storeKind)")

            stack.destroyAndRecreateStore()

            XCTAssertEqual(try countSections(in: stack.context), 0, "\(storeKind)")
            insertTestSection(into: stack.context)
            stack.save()
            XCTAssertEqual(try countSections(in: stack.context), 1, "\(storeKind)")
        }
        // The recreated file store persists new data
        XCTAssertEqual(try countSections(in: makeStack().context), 1)
    }

    func testIsStoreCompatible() throws {
        XCTAssertTrue(isStoreCompatible())

        try makeTwoFASStore(version: "TwoFAS6", at: storeFileURL(".sqlite"), sectionCount: 1)
        XCTAssertFalse(isStoreCompatible())

        CoreDataStack.destroyStoreFiles(name: twoFASStoreName, directory: directory)
        let stack = makeStack()
        insertTestSection(into: stack.context)
        stack.save()
        XCTAssertTrue(isStoreCompatible())
    }

    func testIsStoreCompatibleIsFalseForUnreadableStore() {
        FileManager.default.createFile(atPath: storeFileURL(".sqlite").path, contents: Data("not a store".utf8))
        XCTAssertFalse(isStoreCompatible())
    }

    func testStoreCompatibility() throws {
        func compatibility() -> StoreCompatibility {
            CoreDataStack.storeCompatibility(name: twoFASStoreName, bundle: twoFASModelBundle, directory: directory)
        }
        XCTAssertEqual(compatibility(), .noStore)

        try makeTwoFASStore(version: "TwoFAS6", at: storeFileURL(".sqlite"), sectionCount: 1)
        XCTAssertEqual(compatibility(), .incompatible)

        CoreDataStack.destroyStoreFiles(name: twoFASStoreName, directory: directory)
        let stack = makeStack()
        insertTestSection(into: stack.context)
        stack.save()
        XCTAssertEqual(compatibility(), .compatible)

        CoreDataStack.destroyStoreFiles(name: twoFASStoreName, directory: directory)
        FileManager.default.createFile(atPath: storeFileURL(".sqlite").path, contents: Data("not a store".utf8))
        XCTAssertEqual(compatibility(), .unreadable)
    }
}
