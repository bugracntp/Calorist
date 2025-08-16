import Foundation

struct User: Identifiable, Codable {
    var id: UUID
    var name: String
    var age: Int
    var gender: Gender
    var activityLevel: ActivityLevel
    var goal: Goal
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String, age: Int, gender: Gender, activityLevel: ActivityLevel, goal: Goal) {
        self.id = UUID()
        self.name = name
        self.age = age
        self.gender = gender
        self.activityLevel = activityLevel
        self.goal = goal
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    init(id: UUID, name: String, age: Int, gender: Gender, activityLevel: ActivityLevel, goal: Goal, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.age = age
        self.gender = gender
        self.activityLevel = activityLevel
        self.goal = goal
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum Gender: String, CaseIterable, Codable {
    case male = "male"
    case female = "female"
    
    var displayName: String {
        switch self {
        case .male: return "Erkek"
        case .female: return "Kadın"
        }
    }
}

enum ActivityLevel: String, CaseIterable, Codable {
    case sedentary = "sedentary"
    case lightlyActive = "lightlyActive"
    case moderatelyActive = "moderatelyActive"
    case veryActive = "veryActive"
    case extremelyActive = "extremelyActive"
    
    var displayName: String {
        switch self {
        case .sedentary: return "Hareketsiz"
        case .lightlyActive: return "Az Hareketli"
        case .moderatelyActive: return "Orta Hareketli"
        case .veryActive: return "Çok Hareketli"
        case .extremelyActive: return "Aşırı Hareketli"
        }
    }
    
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .lightlyActive: return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive: return 1.725
        case .extremelyActive: return 1.9
        }
    }
}

enum Goal: String, CaseIterable, Codable {
    case loseWeight = "loseWeight"
    case maintainWeight = "maintainWeight"
    case gainWeight = "gainWeight"
    
    var displayName: String {
        switch self {
        case .loseWeight: return "Kilo Ver"
        case .maintainWeight: return "Kilo Koru"
        case .gainWeight: return "Kilo Al"
        }
    }
}
