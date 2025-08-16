import Foundation
import CoreData

// Import User entity from Domain layer
// Note: In a real project, you might need to adjust the import path
struct UserDTO: Codable {
    var id: String
    let name: String
    let age: Int
    let gender: String

    let activityLevel: String
    let goal: String
    let createdAt: Date
    let updatedAt: Date
    
    init(from user: User) {
        self.id = user.id.uuidString
        self.name = user.name
        self.age = user.age
        self.gender = user.gender.rawValue
        self.activityLevel = user.activityLevel.rawValue
        self.goal = user.goal.rawValue
        self.createdAt = user.createdAt
        self.updatedAt = user.updatedAt
    }
    
    init(id: String, name: String, age: Int, gender: String, activityLevel: String, goal: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.age = age
        self.gender = gender
        self.activityLevel = activityLevel
        self.goal = goal
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
        func toUser() -> User? {
        guard let gender = Gender(rawValue: gender),
              let activityLevel = ActivityLevel(rawValue: activityLevel),
              let goal = Goal(rawValue: goal),
              let id = UUID(uuidString: id) else {
            print("DEBUG: UserDTO.toUser() - Parsing hatası: gender=\(gender), activityLevel=\(activityLevel), goal=\(goal), id=\(id)")
            return nil
        }

        return User(
            id: id,
            name: name,
            age: age,
            gender: gender,
            activityLevel: activityLevel,
            goal: goal,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
