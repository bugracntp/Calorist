import Foundation

protocol DailyTrackingRepository {
    func getDailyTracking(for userId: UUID, on date: Date) async throws -> DailyTracking?
    func saveDailyTracking(_ tracking: DailyTracking) async throws
    func getDailyTrackingGoals(for userId: UUID) async throws -> DailyTrackingGoals?
    func saveDailyTrackingGoals(_ goals: DailyTrackingGoals) async throws
    func getWeeklyTracking(for userId: UUID, startDate: Date) async throws -> [DailyTracking]
    func getMonthlyTracking(for userId: UUID, month: Int, year: Int) async throws -> [DailyTracking]
}
