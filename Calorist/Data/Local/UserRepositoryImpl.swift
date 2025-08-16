import Foundation
import CoreData

// Import entities and repositories from Domain layer
// Note: In a real project, you might need to adjust the import paths
class UserRepositoryImpl: UserRepository {
    private let coreDataManager = CoreDataManager.shared
    
    func save(_ user: User) async throws {
        let context = coreDataManager.context
        
        // Context'i temizle
        context.rollback()
        
        // Önce mevcut kullanıcıyı sil
        try await deleteExistingUsers()
        
        // Yeni kullanıcıyı kaydet
        let userEntity = UserEntity(context: context)
        userEntity.id = user.id.uuidString
        userEntity.name = user.name
        userEntity.age = Int32(user.age)
        userEntity.gender = user.gender.rawValue
        userEntity.activityLevel = user.activityLevel.rawValue
        userEntity.goal = user.goal.rawValue
        userEntity.createdAt = user.createdAt
        userEntity.updatedAt = user.updatedAt
        
        print("DEBUG: User kaydediliyor - id: \(user.id), name: \(user.name), gender: \(user.gender.rawValue), activity: \(user.activityLevel.rawValue), goal: \(user.goal.rawValue)")
        
        // Context'i kaydet
        coreDataManager.saveContext()
        
        // Kaydedilen entity'yi doğrula
        guard let savedUser = try await getCurrentUser() else {
            throw NSError(domain: "UserRepository", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı kaydedildi ama geri yüklenemedi"])
        }
        
        print("DEBUG: User başarıyla kaydedildi ve doğrulandı: \(savedUser.name)")
    }
    
    func getCurrentUser() async throws -> User? {
        let context = coreDataManager.context
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        let results = try context.fetch(fetchRequest)
        guard let userEntity = results.first else { return nil }
        
        // Güvenli veri çıkarma
        guard let idString = userEntity.id,
              !idString.isEmpty,
              let id = UUID(uuidString: idString),
              let name = userEntity.name,
              !name.isEmpty else {
            print("DEBUG: UserEntity'de gerekli alanlar eksik veya boş")
            return nil
        }
        
        // Enum değerlerini güvenli şekilde parse et
        let gender: Gender
        if let genderString = userEntity.gender, !genderString.isEmpty {
            gender = Gender(rawValue: genderString) ?? .male
        } else {
            gender = .male
        }
        
        let activityLevel: ActivityLevel
        if let activityString = userEntity.activityLevel, !activityString.isEmpty {
            activityLevel = ActivityLevel(rawValue: activityString) ?? .sedentary
        } else {
            activityLevel = .sedentary
        }
        
        let goal: Goal
        if let goalString = userEntity.goal, !goalString.isEmpty {
            goal = Goal(rawValue: goalString) ?? .maintainWeight
        } else {
            goal = .maintainWeight
        }
        
        // User entity'sini doğrudan oluştur
        return User(
            id: id,
            name: name,
            age: Int(userEntity.age),
            gender: gender,
            activityLevel: activityLevel,
            goal: goal,
            createdAt: userEntity.createdAt ?? Date(),
            updatedAt: userEntity.updatedAt ?? Date()
        )
    }
    
    func update(_ user: User) async throws {
        try await save(user)
    }
    func delete(_ user: User) async throws {
        let context = coreDataManager.context
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", user.id.uuidString)
        
        let results = try context.fetch(fetchRequest)
        results.forEach { context.delete($0) }
        
        coreDataManager.saveContext()
    }
    
    private func deleteExistingUsers() async throws {
        let context = coreDataManager.context
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        
        let results = try context.fetch(fetchRequest)
        results.forEach { context.delete($0) }
        
        coreDataManager.saveContext()
    }
}
