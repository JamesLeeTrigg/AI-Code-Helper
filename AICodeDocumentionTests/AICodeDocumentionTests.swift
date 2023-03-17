import XCTest
@testable import AICodeDocumention

final class AICodeDocumentionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCoreDataStackSetup() {
        let persistenceController = PersistenceController.shared
        XCTAssertNotNil(persistenceController.container, "CoreData stack not set up properly")
    }

    func testAddItemToCoreData() {
        let persistenceController = PersistenceController.shared
        let viewContext = persistenceController.container.viewContext
        let newItem = Item(context: viewContext)
        newItem.timestamp = Date()

        XCTAssertNoThrow(try viewContext.save(), "Failed to add item to CoreData")
    }

    func testFetchItemsFromCoreData() {
        let persistenceController = PersistenceController.shared
        let viewContext = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()

        XCTAssertNoThrow(try viewContext.fetch(fetchRequest), "Failed to fetch items from CoreData")
    }
}
