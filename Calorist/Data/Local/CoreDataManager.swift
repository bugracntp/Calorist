import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Calorist")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("DEBUG: Core Data store failed to load: \(error)")
                // fatalError yerine sadece log yazdır
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    func saveContext() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
            print("DEBUG: Core Data context başarıyla kaydedildi")
        } catch {
            let nsError = error as NSError
            print("DEBUG: Core Data save hatası: \(nsError), \(nsError.userInfo)")
            
            // Context'i reset et ve tekrar dene
            context.rollback()
            
            do {
                try context.save()
                print("DEBUG: Core Data context rollback sonrası başarıyla kaydedildi")
            } catch {
                print("DEBUG: Core Data context rollback sonrası da kaydedilemedi: \(error)")
            }
        }
    }
    
    func deleteAllData() {
        let entities = persistentContainer.managedObjectModel.entities
        entities.forEach { entity in
            guard let entityName = entity.name else { return }
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                print("DEBUG: \(entityName) entity'si başarıyla silindi")
            } catch {
                print("DEBUG: \(entityName) entity'si silinirken hata: \(error)")
            }
        }
        saveContext()
    }
    
    // Context'i temizle ve yeniden oluştur
    func resetContext() {
        context.rollback()
        print("DEBUG: Core Data context reset edildi")
    }
}
