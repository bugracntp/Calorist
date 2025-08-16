import Foundation
import SwiftUI

@MainActor
class DailyTrackingViewModel: ObservableObject {
    @Published var currentTracking: DailyTracking?
    @Published var trackingGoals: DailyTrackingGoals?
    @Published var weeklyTracking: [DailyTracking] = []
    @Published var selectedDate = Date()
    @Published var calorieIntake: String = ""
    @Published var waterIntake: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingSaveAlert = false
    
    private let repository: DailyTrackingRepository
    private var userId: UUID
    
    init(repository: DailyTrackingRepository, userId: UUID) {
        self.repository = repository
        self.userId = userId
    }
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let trackingTask = repository.getDailyTracking(for: userId, on: selectedDate)
            async let goalsTask = repository.getDailyTrackingGoals(for: userId)
            async let weeklyTask = repository.getWeeklyTracking(for: userId, startDate: getStartOfWeek())
            
            let (tracking, goals, weekly) = try await (trackingTask, goalsTask, weeklyTask)
            
            currentTracking = tracking
            trackingGoals = goals
            weeklyTracking = weekly
            
            // Set current values for editing
            if let tracking = tracking {
                calorieIntake = String(format: "%.0f", tracking.calorieIntake)
                waterIntake = String(format: "%.1f", tracking.waterIntake)
            } else {
                calorieIntake = ""
                waterIntake = ""
            }
            
            // Set default goals if none exist
            if trackingGoals == nil {
                trackingGoals = DailyTrackingGoals(
                    userId: userId,
                    dailyCalorieGoal: 2000.0,
                    dailyWaterGoal: 2.5
                )
            }
            
        } catch {
            errorMessage = "Veri yüklenirken hata oluştu: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func saveTracking() async {
        guard let calorieValue = Double(calorieIntake),
              let waterValue = Double(waterIntake) else {
            errorMessage = "Lütfen geçerli değerler girin"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let tracking = DailyTracking(
                userId: userId,
                date: selectedDate,
                calorieIntake: calorieValue,
                waterIntake: waterValue
            )
            
            try await repository.saveDailyTracking(tracking)
            currentTracking = tracking
            showingSaveAlert = true
            
            // Reload weekly data
            weeklyTracking = try await repository.getWeeklyTracking(for: userId, startDate: getStartOfWeek())
            
        } catch {
            errorMessage = "Kaydetme sırasında hata oluştu: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func saveGoals() async {
        guard let goals = trackingGoals else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await repository.saveDailyTrackingGoals(goals)
            showingSaveAlert = true
        } catch {
            errorMessage = "Hedefler kaydedilirken hata oluştu: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func changeDate(_ date: Date) {
        selectedDate = date
        Task {
            await loadData()
        }
    }
    
    func updateUserId(_ newUserId: UUID) {
        userId = newUserId
        Task {
            await loadData()
        }
    }
    
    func getStartOfWeek() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)
        return calendar.date(from: components) ?? selectedDate
    }
    
    func getProgressPercentage(for type: ProgressType) -> Double {
        guard let goals = trackingGoals else { return 0.0 }
        
        switch type {
        case .calories:
            let current = currentTracking?.calorieIntake ?? 0
            return min(current / goals.dailyCalorieGoal, 1.0)
        case .water:
            let current = currentTracking?.waterIntake ?? 0
            return min(current / goals.dailyWaterGoal, 1.0)
        }
    }
    
    func getWeeklyAverage(for type: ProgressType) -> Double {
        guard !weeklyTracking.isEmpty else { return 0.0 }
        
        let total: Double
        switch type {
        case .calories:
            total = weeklyTracking.reduce(0) { $0 + $1.calorieIntake }
        case .water:
            total = weeklyTracking.reduce(0) { $0 + $1.waterIntake }
        }
        
        return total / Double(weeklyTracking.count)
    }
    
    var weeklyAverageCalories: Double {
        return getWeeklyAverage(for: .calories)
    }
    
    var weeklyAverageWater: Double {
        return getWeeklyAverage(for: .water)
    }
}

enum ProgressType {
    case calories
    case water
}
