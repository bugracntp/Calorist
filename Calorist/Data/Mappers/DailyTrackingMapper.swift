import Foundation

struct DailyTrackingMapper {
    static func toEntity(from dto: DailyTrackingDTO) -> DailyTracking {
        return DailyTracking(
            id: dto.id,
            userId: dto.userId,
            date: dto.date,
            calorieIntake: dto.calorieIntake,
            waterIntake: dto.waterIntake,
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt
        )
    }
    
    static func toDTO(from entity: DailyTracking) -> DailyTrackingDTO {
        return DailyTrackingDTO(
            id: entity.id,
            userId: entity.userId,
            date: entity.date,
            calorieIntake: entity.calorieIntake,
            waterIntake: entity.waterIntake,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt
        )
    }
    
    static func toEntity(from dto: DailyTrackingGoalsDTO) -> DailyTrackingGoals {
        return DailyTrackingGoals(
            userId: dto.userId,
            dailyCalorieGoal: dto.dailyCalorieGoal,
            dailyWaterGoal: dto.dailyWaterGoal,
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt
        )
    }
    
    static func toDTO(from entity: DailyTrackingGoals) -> DailyTrackingGoalsDTO {
        return DailyTrackingGoalsDTO(
            userId: entity.userId,
            dailyCalorieGoal: entity.dailyCalorieGoal,
            dailyWaterGoal: entity.dailyWaterGoal,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt
        )
    }
}
