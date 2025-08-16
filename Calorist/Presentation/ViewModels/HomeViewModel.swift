import Foundation
import SwiftUI

// Import entities, repositories, and use cases from Domain layer
// Note: In a real project, you might need to adjust the import paths
@MainActor
class HomeViewModel: ObservableObject {
    @Published var user: User?
    @Published var bodyMetrics: BodyMetrics?
    @Published var dailyCalories: Double = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userRepository: UserRepository
    private let measurementRepository: MeasurementRepository
    private let calculateBodyMetricsUseCase: CalculateBodyMetricsUseCase
    private let calculateDailyCaloriesUseCase: CalculateDailyCaloriesUseCase
    
    init(userRepository: UserRepository = UserRepositoryImpl(),
         measurementRepository: MeasurementRepository = MeasurementRepositoryImpl(),
         calculateBodyMetricsUseCase: CalculateBodyMetricsUseCase = CalculateBodyMetricsUseCaseImpl(),
         calculateDailyCaloriesUseCase: CalculateDailyCaloriesUseCase = CalculateDailyCaloriesUseCaseImpl()) {
        self.userRepository = userRepository
        self.measurementRepository = measurementRepository
        self.calculateBodyMetricsUseCase = calculateBodyMetricsUseCase
        self.calculateDailyCaloriesUseCase = calculateDailyCaloriesUseCase
    }
    
    func loadUserData() async {
        print("DEBUG: loadUserData başladı")
        isLoading = true
        errorMessage = nil
        
        do {
            user = try await userRepository.getCurrentUser()
            print("DEBUG: User yüklendi: \(user?.name ?? "nil")")
            
            if let user = user {
                // En son ölçümü al ve BodyMetrics hesapla
                if let latestMeasurement = try await measurementRepository.getLatest(for: user.id) {
                    print("DEBUG: Latest measurement bulundu: weight=\(latestMeasurement.weight), height=\(latestMeasurement.height)")
                    
                    bodyMetrics = calculateBodyMetricsUseCase.execute(measurement: latestMeasurement, user: user)
                    print("DEBUG: BodyMetrics hesaplandı: \(bodyMetrics != nil)")
                    
                    // Günlük kaloriyi de hesapla
                    dailyCalories = calculateDailyCaloriesUseCase.execute(measurement: latestMeasurement, user: user)
                    print("DEBUG: Daily calories hesaplandı: \(dailyCalories)")
                } else {
                    print("DEBUG: Latest measurement bulunamadı")
                }
            } else {
                print("DEBUG: User bulunamadı")
            }
        } catch {
            print("DEBUG: loadUserData hatası: \(error)")
            errorMessage = "Kullanıcı verileri yüklenirken hata oluştu: \(error.localizedDescription)"
        }
        
        isLoading = false
        print("DEBUG: loadUserData tamamlandı")
    }
    
    func saveUser(_ user: User, withInitialMeasurement measurement: Measurement) async {
        print("DEBUG: saveUser başladı - \(user.name)")
        isLoading = true
        errorMessage = nil
        
        do {
            // Önce kullanıcıyı kaydet
            print("DEBUG: Kullanıcı kaydediliyor...")
            try await userRepository.save(user)
            print("DEBUG: Kullanıcı kaydedildi")
            self.user = user
            
            // Sonra ilk ölçümü kaydet
            print("DEBUG: Ölçüm kaydediliyor...")
            try await measurementRepository.save(measurement)
            print("DEBUG: Ölçüm kaydedildi")
            
            // BodyMetrics'i hesapla
            print("DEBUG: BodyMetrics hesaplanıyor...")
            bodyMetrics = calculateBodyMetricsUseCase.execute(measurement: measurement, user: user)
            print("DEBUG: BodyMetrics hesaplandı")
            
            // Günlük kaloriyi hesapla
            print("DEBUG: Günlük kalori hesaplanıyor...")
            dailyCalories = calculateDailyCaloriesUseCase.execute(measurement: measurement, user: user)
            print("DEBUG: Günlük kalori hesaplandı: \(dailyCalories)")
            
            print("DEBUG: saveUser tamamlandı - user: \(self.user?.name ?? "nil"), bodyMetrics: \(bodyMetrics != nil)")
            
        } catch {
            print("DEBUG: Hata oluştu: \(error)")
            errorMessage = "Kullanıcı kaydedilirken hata oluştu: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func hasUserData() -> Bool {
        return user != nil
    }
    
    func updateUser(_ updatedUser: User) async {
        print("DEBUG: updateUser başladı - \(updatedUser.name)")
        isLoading = true
        errorMessage = nil
        
        do {
            // Kullanıcıyı güncelle
            try await userRepository.save(updatedUser)
            print("DEBUG: Kullanıcı güncellendi")
            self.user = updatedUser
            
            // Eğer mevcut ölçüm varsa, yeni ayarlarla yeniden hesapla
            if let latestMeasurement = try await measurementRepository.getLatest(for: updatedUser.id) {
                print("DEBUG: BodyMetrics yeniden hesaplanıyor...")
                bodyMetrics = calculateBodyMetricsUseCase.execute(measurement: latestMeasurement, user: updatedUser)
                
                print("DEBUG: Günlük kalori yeniden hesaplanıyor...")
                dailyCalories = calculateDailyCaloriesUseCase.execute(measurement: latestMeasurement, user: updatedUser)
                print("DEBUG: Günlük kalori güncellendi: \(dailyCalories)")
            }
            
            print("DEBUG: updateUser tamamlandı")
            
        } catch {
            print("DEBUG: updateUser hatası: \(error)")
            errorMessage = "Kullanıcı güncellenirken hata oluştu: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
