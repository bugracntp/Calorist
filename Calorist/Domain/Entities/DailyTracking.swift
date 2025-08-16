import Foundation

struct DailyTracking: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let date: Date
    let calorieIntake: Double
    let waterIntake: Double // in liters
    let createdAt: Date
    let updatedAt: Date
    
    init(id: UUID = UUID(), userId: UUID, date: Date, calorieIntake: Double, waterIntake: Double, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.date = date
        self.calorieIntake = calorieIntake
        self.waterIntake = waterIntake
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// Daily tracking goals
struct DailyTrackingGoals: Codable {
    let userId: UUID
    let dailyCalorieGoal: Double
    let dailyWaterGoal: Double // in liters
    let createdAt: Date
    let updatedAt: Date
    
    init(userId: UUID, dailyCalorieGoal: Double, dailyWaterGoal: Double, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.userId = userId
        self.dailyCalorieGoal = dailyCalorieGoal
        self.dailyWaterGoal = dailyWaterGoal
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
