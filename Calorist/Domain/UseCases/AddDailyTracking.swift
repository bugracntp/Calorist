import Foundation

struct AddDailyTracking {
    private let repository: DailyTrackingRepository
    
    init(repository: DailyTrackingRepository) {
        self.repository = repository
    }
    
    func execute(userId: UUID, date: Date, calorieIntake: Double, waterIntake: Double) async throws {
        let tracking = DailyTracking(
            userId: userId,
            date: date,
            calorieIntake: calorieIntake,
            waterIntake: waterIntake
        )
        
        try await repository.saveDailyTracking(tracking)
    }
}
