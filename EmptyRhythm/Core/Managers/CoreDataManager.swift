import CoreData
import CloudKit

// MARK: - CoreData 管理器（支持 iCloud 同步）
final class CoreDataManager {

    static let shared = CoreDataManager()
    private init() {}

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "EmptyRhythm")

        // 主存储（iCloud 同步：断食记录、方案、配置）
        let cloudStoreURL = NSPersistentContainer.defaultDirectoryURL()
            .appendingPathComponent("EmptyRhythm.sqlite")
        let cloudDesc = NSPersistentStoreDescription(url: cloudStoreURL)
        cloudDesc.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.com.emptythythm.app"
        )
        cloudDesc.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        cloudDesc.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        // 本地存储（不同步：体重、饮食、AI、用户档案）
        let localStoreURL = NSPersistentContainer.defaultDirectoryURL()
            .appendingPathComponent("EmptyRhythmLocal.sqlite")
        let localDesc = NSPersistentStoreDescription(url: localStoreURL)
        localDesc.configuration = "Local"

        container.persistentStoreDescriptions = [cloudDesc, localDesc]

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData 加载失败: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()

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
