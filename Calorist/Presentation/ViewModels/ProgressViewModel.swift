import Foundation
import SwiftUI

// Import entities and repositories from Domain layer
// Note: In a real project, you might need to adjust the import paths
@MainActor
class ProgressViewModel: ObservableObject {
    @Published var measurements: [Measurement] = []
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let measurementRepository: MeasurementRepository
    private let userRepository: UserRepository
    
    init(measurementRepository: MeasurementRepository = MeasurementRepositoryImpl(),
         userRepository: UserRepository = UserRepositoryImpl()) {
        self.measurementRepository = measurementRepository
        self.userRepository = userRepository
    }
    
    func loadMeasurements() async {
        guard let user = try? await userRepository.getCurrentUser() else { return }
        
        self.user = user
        isLoading = true
        errorMessage = nil
        
        do {
            measurements = try await measurementRepository.getAll(for: user.id)
        } catch {
            errorMessage = "Ölçümler yüklenirken hata oluştu: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func addMeasurement(_ measurement: Measurement) async {
        errorMessage = nil
        
        do {
            try await measurementRepository.save(measurement)
            // Sadece yeni ölçümü ekle, tüm listeyi yeniden yükleme
            measurements.append(measurement)
            // Tarihe göre sırala
            measurements.sort { $0.date > $1.date }
        } catch {
            errorMessage = "Ölçüm kaydedilirken hata oluştu: \(error.localizedDescription)"
        }
    }
    
    func deleteMeasurement(_ measurement: Measurement) async {
        errorMessage = nil
        
        do {
            try await measurementRepository.delete(measurement)
            // Sadece silinen ölçümü listeden çıkar
            measurements.removeAll { $0.id == measurement.id }
        } catch {
            errorMessage = "Ölçüm silinirken hata oluştu: \(error.localizedDescription)"
        }
    }
    
    func getWeightProgress() -> [Double] {
        return measurements.sorted { $0.date < $1.date }.map { $0.weight }
    }
    
    func getDates() -> [Date] {
        return measurements.sorted { $0.date < $1.date }.map { $0.date }
    }
    
    func getLatestWeight() -> Double? {
        return measurements.max(by: { $0.date < $1.date })?.weight
    }
    
    func getWeightChange() -> Double? {
        guard measurements.count >= 2 else { return nil }
        let sortedMeasurements = measurements.sorted { $0.date < $1.date }
        guard let firstWeight = sortedMeasurements.first?.weight,
              let lastWeight = sortedMeasurements.last?.weight else { return nil }
        return lastWeight - firstWeight
    }
}
