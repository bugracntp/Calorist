import Foundation

protocol CalculateDailyCaloriesUseCase {
    func execute(measurement: Measurement, user: User) -> Double
}

struct CalculateDailyCaloriesUseCaseImpl: CalculateDailyCaloriesUseCase {
    func execute(measurement: Measurement, user: User) -> Double {
        // Mifflin-St Jeor equation kullanarak BMR hesaplama
        let bmr: Double
        if user.gender == .male {
            bmr = (10 * measurement.weight) + (6.25 * measurement.height) - (5 * Double(user.age)) + 5
        } else {
            bmr = (10 * measurement.weight) + (6.25 * measurement.height) - (5 * Double(user.age)) - 161
        }
        
        // Aktivite seviyesine göre çarpan uygulama
        let tdee = bmr * user.activityLevel.multiplier
        
        // Hedefe göre kalori ayarlama
        switch user.goal {
        case .loseWeight:
            return tdee - 500 // Günlük 500 kalori eksik
        case .maintainWeight:
            return tdee
        case .gainWeight:
            return tdee + 300 // Günlük 300 kalori fazla
        }
    }
}
