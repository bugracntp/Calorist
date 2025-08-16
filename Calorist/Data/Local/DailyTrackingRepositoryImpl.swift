import Foundation
import CoreData

class DailyTrackingRepositoryImpl: DailyTrackingRepository {
    private let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    func getDailyTracking(for userId: UUID, on date: Date) async throws -> DailyTracking? {
        let context = coreDataManager.persistentContainer.viewContext
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request: NSFetchRequest<DailyTrackingEntity> = DailyTrackingEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@ AND date >= %@ AND date < %@", 
                                      userId.uuidString, startOfDay as NSDate, endOfDay as NSDate)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            guard let entity = results.first else { return nil }
            
            return DailyTracking(
                id: UUID(uuidString: entity.id ?? "") ?? UUID(),
                userId: UUID(uuidString: entity.userId ?? "") ?? UUID(),
                date: entity.date ?? Date(),
                calorieIntake: entity.calorieIntake,
                waterIntake: entity.waterIntake,
                createdAt: entity.createdAt ?? Date(),
                updatedAt: entity.updatedAt ?? Date()
            )
        } catch {
            throw error
        }
    }
    
    func saveDailyTracking(_ tracking: DailyTracking) async throws {
        let context = coreDataManager.persistentContainer.viewContext
        
        // Check if tracking already exists for this date
        let existingTracking = try await getDailyTracking(for: tracking.userId, on: tracking.date)
        
        if let existing = existingTracking {
            // Update existing
            let request: NSFetchRequest<DailyTrackingEntity> = DailyTrackingEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", existing.id.uuidString)
            
            do {
                let results = try context.fetch(request)
                if let entity = results.first {
                    entity.calorieIntake = tracking.calorieIntake
                    entity.waterIntake = tracking.waterIntake
                    entity.updatedAt = Date()
                }
            } catch {
                throw error
            }
        } else {
            // Create new
            let entity = DailyTrackingEntity(context: context)
            entity.id = tracking.id.uuidString
            entity.userId = tracking.userId.uuidString
            entity.date = tracking.date
            entity.calorieIntake = tracking.calorieIntake
            entity.waterIntake = tracking.waterIntake
            entity.createdAt = tracking.createdAt
            entity.updatedAt = tracking.updatedAt
        }
        
        try context.save()
    }
    
    func getDailyTrackingGoals(for userId: UUID) async throws -> DailyTrackingGoals? {
        let context = coreDataManager.persistentContainer.viewContext
        
        let request: NSFetchRequest<DailyTrackingGoalsEntity> = DailyTrackingGoalsEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId.uuidString)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            guard let entity = results.first else { return nil }
            
            return DailyTrackingGoals(
                userId: UUID(uuidString: entity.userId ?? "") ?? UUID(),
                dailyCalorieGoal: entity.dailyCalorieGoal,
                dailyWaterGoal: entity.dailyWaterGoal,
                createdAt: entity.createdAt ?? Date(),
                updatedAt: entity.updatedAt ?? Date()
            )
        } catch {
            throw error
        }
    }
    
    func saveDailyTrackingGoals(_ goals: DailyTrackingGoals) async throws {
        let context = coreDataManager.persistentContainer.viewContext
        
        // Check if goals already exist
        let existingGoals = try await getDailyTrackingGoals(for: goals.userId)
        
        if existingGoals != nil {
            // Update existing
            let request: NSFetchRequest<DailyTrackingGoalsEntity> = DailyTrackingGoalsEntity.fetchRequest()
            request.predicate = NSPredicate(format: "userId == %@", goals.userId.uuidString)
            
            do {
                let results = try context.fetch(request)
                if let entity = results.first {
                    entity.dailyCalorieGoal = goals.dailyCalorieGoal
                    entity.dailyWaterGoal = goals.dailyWaterGoal
                    entity.updatedAt = Date()
                }
            } catch {
                throw error
            }
        } else {
            // Create new
            let entity = DailyTrackingGoalsEntity(context: context)
            entity.userId = goals.userId.uuidString
            entity.dailyCalorieGoal = goals.dailyCalorieGoal
            entity.dailyWaterGoal = goals.dailyWaterGoal
            entity.createdAt = goals.createdAt
            entity.updatedAt = goals.updatedAt
        }
        
        try context.save()
    }
    
    func getWeeklyTracking(for userId: UUID, startDate: Date) async throws -> [DailyTracking] {
        let context = coreDataManager.persistentContainer.viewContext
        
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .day, value: 7, to: startDate)!
        
        let request: NSFetchRequest<DailyTrackingEntity> = DailyTrackingEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@ AND date >= %@ AND date < %@", 
                                      userId.uuidString, startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            let results = try context.fetch(request)
            return results.compactMap { entity in
                guard let id = entity.id,
                      let entityUserId = entity.userId,
                      let date = entity.date,
                      let createdAt = entity.createdAt,
                      let updatedAt = entity.updatedAt else { return nil }
                
                return DailyTracking(
                    id: UUID(uuidString: id) ?? UUID(),
                    userId: UUID(uuidString: entityUserId) ?? UUID(),
                    date: date,
                    calorieIntake: entity.calorieIntake,
                    waterIntake: entity.waterIntake,
                    createdAt: createdAt,
                    updatedAt: updatedAt
                )
            }
        } catch {
            throw error
        }
    }
    
    func getMonthlyTracking(for userId: UUID, month: Int, year: Int) async throws -> [DailyTracking] {
        let context = coreDataManager.persistentContainer.viewContext
        
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        guard let startDate = calendar.date(from: components),
              let endDate = calendar.date(byAdding: .month, value: 1, to: startDate) else {
            throw NSError(domain: "InvalidDate", code: -1, userInfo: nil)
        }
        
        let request: NSFetchRequest<DailyTrackingEntity> = DailyTrackingEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@ AND date >= %@ AND date < %@", 
                                      userId.uuidString, startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            let results = try context.fetch(request)
            return results.compactMap { entity in
                guard let id = entity.id,
                      let entityUserId = entity.userId,
                      let date = entity.date,
                      let createdAt = entity.createdAt,
                      let updatedAt = entity.updatedAt else { return nil }
                
                return DailyTracking(
                    id: UUID(uuidString: id) ?? UUID(),
                    userId: UUID(uuidString: entityUserId) ?? UUID(),
                    date: date,
                    calorieIntake: entity.calorieIntake,
                    waterIntake: entity.waterIntake,
                    createdAt: createdAt,
                    updatedAt: updatedAt
                )
            }
        } catch {
            throw error
        }
    }
}
