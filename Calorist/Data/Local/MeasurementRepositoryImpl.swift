import Foundation
import CoreData

// Import entities and repositories from Domain layer
// Note: In a real project, you might need to adjust the import paths
class MeasurementRepositoryImpl: MeasurementRepository {
    private let coreDataManager = CoreDataManager.shared
    
    func save(_ measurement: Measurement) async throws {
        let context = coreDataManager.context
        
        // Context'i temizle
        context.rollback()
        
        let measurementEntity = MeasurementEntity(context: context)
        measurementEntity.id = measurement.id.uuidString
        measurementEntity.userId = measurement.userId.uuidString
        measurementEntity.height = measurement.height
        measurementEntity.weight = measurement.weight
        measurementEntity.neck = measurement.neck
        measurementEntity.waist = measurement.waist
        measurementEntity.hip = measurement.hip
        measurementEntity.arm = measurement.arm
        measurementEntity.date = measurement.date
        
        print("DEBUG: Measurement kaydediliyor - id: \(measurement.id), userId: \(measurement.userId), weight: \(measurement.weight), height: \(measurement.height)")
        
        // Context'i kaydet
        coreDataManager.saveContext()
        
        // Kaydedilen entity'yi doğrula
        guard let savedMeasurement = try await getLatest(for: measurement.userId) else {
            throw NSError(domain: "MeasurementRepository", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Ölçüm kaydedildi ama geri yüklenemedi"])
        }
        
        print("DEBUG: Measurement başarıyla kaydedildi ve doğrulandı: weight=\(savedMeasurement.weight)")
    }
    
    func getAll(for userId: UUID) async throws -> [Measurement] {
        let context = coreDataManager.context
        let fetchRequest: NSFetchRequest<MeasurementEntity> = MeasurementEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", userId.uuidString)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let results = try context.fetch(fetchRequest)
        return results.compactMap { entity in
            // Güvenli veri çıkarma
            guard let idString = entity.id,
                  !idString.isEmpty,
                  let id = UUID(uuidString: idString),
                  let userIdString = entity.userId,
                  !userIdString.isEmpty,
                  let entityUserId = UUID(uuidString: userIdString) else {
                print("DEBUG: MeasurementEntity'de gerekli alanlar eksik veya boş")
                return nil
            }
            
            // Measurement entity'sini doğrudan oluştur
            return Measurement(
                id: id,
                userId: entityUserId,
                height: entity.height,
                weight: entity.weight,
                neck: entity.neck,
                waist: entity.waist,
                hip: entity.hip,
                arm: entity.arm,
                date: entity.date ?? Date()
            )
        }
    }
    
    func getLatest(for userId: UUID) async throws -> Measurement? {
        let context = coreDataManager.context
        let fetchRequest: NSFetchRequest<MeasurementEntity> = MeasurementEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", userId.uuidString)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        let results = try context.fetch(fetchRequest)
        guard let entity = results.first else { return nil }
        
        // Güvenli veri çıkarma
        guard let idString = entity.id,
              !idString.isEmpty,
              let id = UUID(uuidString: idString),
              let userIdString = entity.userId,
              !userIdString.isEmpty,
              let entityUserId = UUID(uuidString: userIdString) else {
            print("DEBUG: MeasurementEntity'de gerekli alanlar eksik veya boş")
            return nil
        }
        
        // Measurement entity'sini doğrudan oluştur
        return Measurement(
            id: id,
            userId: entityUserId,
            height: entity.height,
            weight: entity.weight,
            neck: entity.neck,
            waist: entity.waist,
            hip: entity.hip,
            arm: entity.arm,
            date: entity.date ?? Date()
        )
    }
    
    func delete(_ measurement: Measurement) async throws {
        let context = coreDataManager.context
        let fetchRequest: NSFetchRequest<MeasurementEntity> = MeasurementEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", measurement.id.uuidString)
        
        let results = try context.fetch(fetchRequest)
        results.forEach { context.delete($0) }
        
        coreDataManager.saveContext()
    }
}
