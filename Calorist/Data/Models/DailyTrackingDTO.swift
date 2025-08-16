import Foundation
import CoreData

struct DailyTrackingDTO: Codable {
    let id: UUID
    let userId: UUID
    let date: Date
    let calorieIntake: Double
    let waterIntake: Double
    let createdAt: Date
    let updatedAt: Date
    
    init(from entity: DailyTracking) {
        self.id = entity.id
        self.userId = entity.userId
        self.date = entity.date
        self.calorieIntake = entity.calorieIntake
        self.waterIntake = entity.waterIntake
        self.createdAt = entity.createdAt
        self.updatedAt = entity.updatedAt
    }
    
    init(id: UUID, userId: UUID, date: Date, calorieIntake: Double, waterIntake: Double, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.date = date
        self.calorieIntake = calorieIntake
        self.waterIntake = waterIntake
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct DailyTrackingGoalsDTO: Codable {
    let userId: UUID
    let dailyCalorieGoal: Double
    let dailyWaterGoal: Double
    let createdAt: Date
    let updatedAt: Date
    
    init(from entity: DailyTrackingGoals) {
        self.userId = entity.userId
        self.dailyCalorieGoal = entity.dailyCalorieGoal
        self.dailyWaterGoal = entity.dailyWaterGoal
        self.createdAt = entity.createdAt
        self.updatedAt = entity.updatedAt
    }
    
    init(userId: UUID, dailyCalorieGoal: Double, dailyWaterGoal: Double, createdAt: Date, updatedAt: Date) {
        self.userId = userId
        self.dailyCalorieGoal = dailyCalorieGoal
        self.dailyWaterGoal = dailyWaterGoal
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
