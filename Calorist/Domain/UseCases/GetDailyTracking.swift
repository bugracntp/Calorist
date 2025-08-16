import Foundation

struct GetDailyTracking {
    private let repository: DailyTrackingRepository
    
    init(repository: DailyTrackingRepository) {
        self.repository = repository
    }
    
    func execute(userId: UUID, date: Date) async throws -> DailyTracking? {
        return try await repository.getDailyTracking(for: userId, on: date)
    }
    
    func executeWeekly(userId: UUID, startDate: Date) async throws -> [DailyTracking] {
        return try await repository.getWeeklyTracking(for: userId, startDate: startDate)
    }
    
    func executeMonthly(userId: UUID, month: Int, year: Int) async throws -> [DailyTracking] {
        return try await repository.getMonthlyTracking(for: userId, month: month, year: year)
    }
}
