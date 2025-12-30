import CoreData
import os.log

struct PersistenceController {
    static let shared = PersistenceController()

    private static let logger = Logger(subsystem: "com.BenReeve.Lact8", category: "Persistence")

    let container: NSPersistentContainer

    /// Indicates whether persistence loaded successfully
    private(set) var loadError: Error?

    /// Whether the persistence store loaded successfully
    var isLoaded: Bool { loadError == nil }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Lact8")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        var loadError: Error?

        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                Self.logger.error("Failed to load persistent store: \(error.localizedDescription)")
                loadError = error

                // Attempt recovery by deleting corrupted store
                if let storeURL = storeDescription.url {
                    Self.logger.warning("Attempting to recover by removing corrupted store...")
                    do {
                        try FileManager.default.removeItem(at: storeURL)
                        Self.logger.info("Removed corrupted store, will recreate on next launch")
                    } catch {
                        Self.logger.error("Failed to remove corrupted store: \(error.localizedDescription)")
                    }
                }
            }
        }

        self.loadError = loadError
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // MARK: - Save Context

    func save() throws {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                Self.logger.error("Failed to save context: \(error.localizedDescription)")
                throw Lact8Error.persistenceSaveFailed(underlying: error)
            }
        }
    }

    // MARK: - Convenience Methods

    func deleteTest(_ entity: TestEntity) throws {
        let context = container.viewContext
        context.delete(entity)
        try save()
    }
}
