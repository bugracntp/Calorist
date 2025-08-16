import Foundation

struct Measurement: Identifiable, Codable {
    var id: UUID
    let userId: UUID
    var height: Double // cm cinsinden
    var weight: Double // kg cinsinden
    var neck: Double // cm cinsinden
    var waist: Double // cm cinsinden
    var hip: Double // cm cinsinden
    var arm: Double // cm cinsinden (kol ölçüsü)
    var date: Date
    
    init(userId: UUID, height: Double, weight: Double, neck: Double, waist: Double, hip: Double, arm: Double) {
        self.id = UUID()
        self.userId = userId
        self.height = height
        self.weight = weight
        self.neck = neck
        self.waist = waist
        self.hip = hip
        self.arm = arm
        self.date = Date()
    }
    
    init(id: UUID, userId: UUID, height: Double, weight: Double, neck: Double, waist: Double, hip: Double, arm: Double, date: Date) {
        self.id = id
        self.userId = userId
        self.height = height
        self.weight = weight
        self.neck = neck
        self.waist = waist
        self.hip = hip
        self.arm = arm
        self.date = date
    }
}

struct BodyMetrics: Codable {
    let bmi: Double
    let bodyFatPercentage: Double
    let waistToHipRatio: Double
    let idealWeight: Double
    let dailyCalorieNeeds: Double
    let armCircumference: Double
    
    init(measurement: Measurement, user: User) {
        // BMI hesaplama
        let heightInMeters = measurement.height / 100
        self.bmi = measurement.weight / (heightInMeters * heightInMeters)
        
        // Vücut yağ oranı hesaplama (US Navy method)
        if user.gender == .male {
            self.bodyFatPercentage = 495 / (1.0324 - 0.19077 * log10(measurement.waist - measurement.neck) + 0.15456 * log10(measurement.height)) - 450
        } else {
            self.bodyFatPercentage = 495 / (1.29579 - 0.35004 * log10(measurement.waist + measurement.hip - measurement.neck) + 0.22100 * log10(measurement.height)) - 450
        }
        
        // Bel-kalça oranı
        self.waistToHipRatio = measurement.waist / measurement.hip
        
        // İdeal kilo hesaplama (Devine formula)
        if user.gender == .male {
            self.idealWeight = 50 + 2.3 * ((measurement.height - 152.4) / 2.54)
        } else {
            self.idealWeight = 45.5 + 2.3 * ((measurement.height - 152.4) / 2.54)
        }
        
        // Günlük kalori ihtiyacı (Mifflin-St Jeor equation)
        var bmr: Double
        if user.gender == .male {
            bmr = (10 * measurement.weight) + (6.25 * measurement.height) - (5 * Double(user.age)) + 5
        } else {
            bmr = (10 * measurement.weight) + (6.25 * measurement.height) - (5 * Double(user.age)) - 161
        }
        
        self.dailyCalorieNeeds = bmr * user.activityLevel.multiplier
        
        // Kol çevresi
        self.armCircumference = measurement.arm
    }
}
