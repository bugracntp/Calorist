//
//  Persistence.swift
//  Calorist
//
//  Created by Bugra Cantepe on 15.08.2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Sample user data for preview
        let sampleUser = UserEntity(context: viewContext)
        sampleUser.id = UUID().uuidString
        sampleUser.name = "Örnek Kullanıcı"
        sampleUser.age = 25
        sampleUser.gender = "male"
        
        sampleUser.activityLevel = "moderatelyActive"
        sampleUser.goal = "maintainWeight"
        sampleUser.createdAt = Date()
        sampleUser.updatedAt = Date()
        
        // Sample measurement data for preview
        let sampleMeasurement = MeasurementEntity(context: viewContext)
        sampleMeasurement.id = UUID().uuidString
        sampleMeasurement.userId = sampleUser.id
                         sampleMeasurement.height = 175.0
                 sampleMeasurement.weight = 70.0
                 sampleMeasurement.neck = 35.0
                 sampleMeasurement.waist = 80.0
                 sampleMeasurement.hip = 95.0
                 sampleMeasurement.arm = 28.0
        sampleMeasurement.date = Date()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Calorist")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
