import SwiftUI

// Import entities and components from Domain and Presentation layers
// Note: In a real project, you might need to adjust the import paths
struct AddMeasurementView: View {
    let userId: UUID
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    @StateObject private var homeViewModel = HomeViewModel()
    
    @State private var height = 170.0
    @State private var weight = 70.0
    @State private var neck = 35.0
    @State private var waist = 80.0
    @State private var hip = 95.0
    @State private var arm = 28.0
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isInitialDataLoaded = false
    
    // Doğrudan repository kullan
    private let measurementRepository: MeasurementRepository = MeasurementRepositoryImpl()
    
    var body: some View {
        NavigationView {
            Form {
                Section(localizationManager.localizedString("body_measurements")) {
                    HStack {
                        Text(localizationManager.localizedString("height"))
                        Spacer()
                        Text("\(String(format: "%.1f", height)) cm")
                    }
                    Slider(value: $height, in: Constants.Health.minHeight...Constants.Health.maxHeight, step: 0.5)

                    HStack {
                        Text(localizationManager.localizedString("weight"))
                        Spacer()
                        Text("\(String(format: "%.1f", weight)) kg")
                    }
                    Slider(value: $weight, in: Constants.Health.minWeight...Constants.Health.maxWeight, step: 0.1)
                    
                    HStack {
                        Text(localizationManager.localizedString("neck"))
                        Spacer()
                        Text("\(String(format: "%.1f", neck)) cm")
                    }
                    Slider(value: $neck, in: 25...50, step: 0.5)
                    
                    HStack {
                        Text(localizationManager.localizedString("waist"))
                        Spacer()
                        Text("\(String(format: "%.1f", waist)) cm")
                    }
                    Slider(value: $waist, in: 60...150, step: 0.5)
                    
                    HStack {
                        Text(localizationManager.localizedString("hip"))
                        Spacer()
                        Text("\(String(format: "%.1f", hip)) cm")
                    }
                    Slider(value: $hip, in: 70...150, step: 0.5)

                    HStack {
                        Text(localizationManager.localizedString("arm"))
                        Spacer()
                        Text("\(String(format: "%.1f", arm)) cm")
                    }
                    Slider(value: $arm, in: 20...50, step: 0.5)
                }
                
                if isInitialDataLoaded {
                    Section(localizationManager.localizedString("previous_measurement_difference")) {
                        let previousMeasurement = getPreviousMeasurement()
                        if let previous = previousMeasurement {
                            HStack {
                                Text(localizationManager.localizedString("weight_change"))
                                Spacer()
                                let weightDiff = weight - previous.weight
                                Text("\(weightDiff >= 0 ? "+" : "")\(String(format: "%.1f", weightDiff)) kg")
                                    .foregroundColor(weightDiff >= 0 ? .red : .green)
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text(localizationManager.localizedString("waist_change"))
                                Spacer()
                                let waistDiff = waist - previous.waist
                                Text("\(waistDiff >= 0 ? "+" : "")\(String(format: "%.1f", waistDiff)) cm")
                                    .foregroundColor(waistDiff >= 0 ? .red : .green)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
                
                Section(localizationManager.localizedString("calculated_values")) {
                    let measurement = Measurement(
                        userId: userId,
                        height: height,
                        weight: weight,
                        neck: neck,
                        waist: waist,
                        hip: hip,
                        arm: arm
                    )
                    
                    if let user = homeViewModel.user {
                        let bodyMetrics = BodyMetrics(measurement: measurement, user: user)
                        
                        HStack {
                                    Text(localizationManager.localizedString("bmi"))
                            Spacer()
                            Text(String(format: "%.1f", bodyMetrics.bmi))
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text(localizationManager.localizedString("body_fat"))
                            Spacer()
                            Text(String(format: "%.1f%%", bodyMetrics.bodyFatPercentage))
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text(localizationManager.localizedString("waist_to_hip_ratio"))
                            Spacer()
                            Text(String(format: "%.2f", bodyMetrics.waistToHipRatio))
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .navigationTitle(localizationManager.localizedString("new_measurement"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localizationManager.localizedString("cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localizationManager.localizedString("save")) {
                        saveMeasurement()
                    }
                    .disabled(isLoading)
                }
            }
            .task {
                await loadInitialData()
            }
            .alert(localizationManager.localizedString("error"), isPresented: .constant(errorMessage != nil)) {
                Button(localizationManager.localizedString("ok")) {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private func loadInitialData() async {
        // Önce kullanıcı bilgilerini yükle
        await homeViewModel.loadUserData()
        
        // Sonra en son ölçümü yükle ve form değerlerini ayarla
        if let latestMeasurement = try? await measurementRepository.getLatest(for: userId) {
            await MainActor.run {
                height = latestMeasurement.height
                weight = latestMeasurement.weight
                neck = latestMeasurement.neck
                waist = latestMeasurement.waist
                hip = latestMeasurement.hip
                arm = latestMeasurement.arm
                isInitialDataLoaded = true
            }
            print("DEBUG: Önceki ölçüm değerleri yüklendi")
        } else {
            // İlk ölçüm ise varsayılan değerleri kullan
            await MainActor.run {
                isInitialDataLoaded = true
            }
            print("DEBUG: İlk ölçüm, varsayılan değerler kullanılıyor")
        }
    }
    
    private func getPreviousMeasurement() -> Measurement? {
        // Bu fonksiyon önceki ölçümü döndürür (şu anki değerler)
        return Measurement(
            userId: userId,
            height: height,
            weight: weight,
            neck: neck,
            waist: waist,
            hip: hip,
            arm: arm
        )
    }
    
    private func saveMeasurement() {
        isLoading = true
        errorMessage = nil
        
        let measurement = Measurement(
            userId: userId,
            height: height,
            weight: weight,
            neck: neck,
            waist: waist,
            hip: hip,
            arm: arm
        )
        
        Task {
            do {
                try await measurementRepository.save(measurement)
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = localizationManager.localizedString("measurement_save_error") + ": \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    AddMeasurementView(userId: UUID())
}
