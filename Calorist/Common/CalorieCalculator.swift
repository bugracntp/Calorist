import Foundation

class CalorieCalculator {
    static func calculateBMR(weight: Double, height: Double, age: Int, gender: Gender) -> Double {
        // Mifflin-St Jeor equation
        if gender == .male {
            return (10 * weight) + (6.25 * height) - (5 * Double(age)) + 5
        } else {
            return (10 * weight) + (6.25 * height) - (5 * Double(age)) - 161
        }
    }
    
    static func calculateTDEE(bmr: Double, activityLevel: ActivityLevel) -> Double {
        return bmr * activityLevel.multiplier
    }
    
    static func calculateDailyCalories(tdee: Double, goal: Goal) -> Double {
        switch goal {
        case .loseWeight:
            return tdee - 500 // Günlük 500 kalori eksik
        case .maintainWeight:
            return tdee
        case .gainWeight:
            return tdee + 300 // Günlük 300 kalori fazla
        }
    }
    
    static func calculateBMI(weight: Double, height: Double) -> Double {
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    static func getBMICategory(bmi: Double) -> String {
        switch bmi {
        case ..<18.5:
            return "Zayıf"
        case 18.5..<25:
            return "Normal"
        case 25..<30:
            return "Fazla Kilolu"
        case 30..<35:
            return "Obez (1. Derece)"
        case 35..<40:
            return "Obez (2. Derece)"
        default:
            return "Aşırı Obez (3. Derece)"
        }
    }
    
    static func calculateBodyFatPercentage(height: Double, weight: Double, age: Int, gender: Gender, waist: Double, neck: Double, hip: Double) -> Double {
        // US Navy method
        if gender == .male {
            return 495 / (1.0324 - 0.19077 * log10(waist - neck) + 0.15456 * log10(height)) - 450
        } else {
            return 495 / (1.29579 - 0.35004 * log10(waist + hip - neck) + 0.22100 * log10(height)) - 450
        }
    }
    
    static func calculateWaistToHipRatio(waist: Double, hip: Double) -> Double {
        return waist / hip
    }
    
    static func getWaistToHipRatioCategory(ratio: Double, gender: Gender) -> String {
        if gender == .male {
            if ratio < 0.9 {
                return "Düşük Risk"
            } else if ratio < 1.0 {
                return "Orta Risk"
            } else {
                return "Yüksek Risk"
            }
        } else {
            if ratio < 0.8 {
                return "Düşük Risk"
            } else if ratio < 0.85 {
                return "Orta Risk"
            } else {
                return "Yüksek Risk"
            }
        }
    }
}
