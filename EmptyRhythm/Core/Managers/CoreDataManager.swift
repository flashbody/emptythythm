import CoreData
import CloudKit

// MARK: - CoreData 管理器（CloudKit 同步 + 本地降级）
final class CoreDataManager {

    static let shared = CoreDataManager()
    private init() {}

    // MARK: - 是否使用 CloudKit（运行时检测）
    private var useCloudKit: Bool {
        // 检查 iCloud 账号是否可用
        if FileManager.default.ubiquityIdentityToken == nil {
            return false
        }
        return true
    }

    lazy var persistentContainer: NSPersistentContainer = {
        if useCloudKit {
            return makeCloudKitContainer()
        } else {
            return makeLocalContainer()
        }
    }()

    // MARK: - CloudKit 容器
    private func makeCloudKitContainer() -> NSPersistentContainer {
        let container = NSPersistentCloudKitContainer(name: "EmptyRhythm")

        let cloudStoreURL = NSPersistentContainer.defaultDirectoryURL()
            .appendingPathComponent("EmptyRhythm.sqlite")
        let cloudDesc = NSPersistentStoreDescription(url: cloudStoreURL)
        cloudDesc.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.com.emptythythm.app"
        )
        cloudDesc.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        cloudDesc.setOption(true as NSNumber,
                            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.persistentStoreDescriptions = [cloudDesc]

        container.loadPersistentStores { _, error in
            if let error = error {
                // CloudKit 加载失败：降级到本地存储，不崩溃
                print("[CoreData] CloudKit 加载失败，降级本地存储: \(error)")
                self.loadLocalFallback(container: container)
                return
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }

    // MARK: - 纯本地容器
    private func makeLocalContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "EmptyRhythm")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("[CoreData] 本地存储加载失败: \(error)")
                // 尝试删除损坏的数据库重建
                self.resetAndReload(container: container)
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }

    // MARK: - CloudKit 失败降级：切换到本地存储
    private func loadLocalFallback(container: NSPersistentContainer) {
        let localURL = NSPersistentContainer.defaultDirectoryURL()
            .appendingPathComponent("EmptyRhythmLocal.sqlite")
        let localDesc = NSPersistentStoreDescription(url: localURL)

        // 移除 CloudKit 描述，换成本地
        container.persistentStoreDescriptions = [localDesc]
        container.loadPersistentStores { _, error in
            if let error = error {
                print("[CoreData] 本地降级也失败: \(error)")
                self.resetAndReload(container: container)
            }
        }
    }

    // MARK: - 数据库损坏时重置重建（最后兜底）
    private func resetAndReload(container: NSPersistentContainer) {
        let storeURL = NSPersistentContainer.defaultDirectoryURL()
            .appendingPathComponent("EmptyRhythm.sqlite")
        let coordinator = container.persistentStoreCoordinator
        // 删除损坏文件
        try? coordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType)
        try? FileManager.default.removeItem(at: storeURL)
        // 重新加载空库
        container.loadPersistentStores { _, error in
            if let error = error {
                print("[CoreData] 重建失败: \(error)")
                // 此时只能给用户提示，不再 fatalError
            }
        }
    }

    // MARK: - 公开接口
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("[CoreData] 保存失败: \(error)")
        }
    }

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
}
