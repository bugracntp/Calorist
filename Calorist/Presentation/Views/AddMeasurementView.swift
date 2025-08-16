import SwiftUI

// Import entities and components from Domain and Presentation layers
// Note: In a real project, you might need to adjust the import paths
struct AddMeasurementView: View {
    let userId: UUID
    
    @Environment(\.dismiss) private var dismiss
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
                Section("Vücut Ölçüleri") {
                    HStack {
                        Text("Boy")
                        Spacer()
                        Text("\(String(format: "%.1f", height)) cm")
                    }
                    Slider(value: $height, in: Constants.Health.minHeight...Constants.Health.maxHeight, step: 0.5)

                    HStack {
                        Text("Kilo")
                        Spacer()
                        Text("\(String(format: "%.1f", weight)) kg")
                    }
                    Slider(value: $weight, in: Constants.Health.minWeight...Constants.Health.maxWeight, step: 0.1)
                    
                    HStack {
                        Text("Boyun")
                        Spacer()
                        Text("\(String(format: "%.1f", neck)) cm")
                    }
                    Slider(value: $neck, in: 25...50, step: 0.5)
                    
                    HStack {
                        Text("Bel")
                        Spacer()
                        Text("\(String(format: "%.1f", waist)) cm")
                    }
                    Slider(value: $waist, in: 60...150, step: 0.5)
                    
                    HStack {
                        Text("Kalça")
                        Spacer()
                        Text("\(String(format: "%.1f", hip)) cm")
                    }
                    Slider(value: $hip, in: 70...150, step: 0.5)

                    HStack {
                        Text("Kol")
                        Spacer()
                        Text("\(String(format: "%.1f", arm)) cm")
                    }
                    Slider(value: $arm, in: 20...50, step: 0.5)
                }
                
                if isInitialDataLoaded {
                    Section("Önceki Ölçümden Fark") {
                        let previousMeasurement = getPreviousMeasurement()
                        if let previous = previousMeasurement {
                            HStack {
                                Text("Kilo Değişimi")
                                Spacer()
                                let weightDiff = weight - previous.weight
                                Text("\(weightDiff >= 0 ? "+" : "")\(String(format: "%.1f", weightDiff)) kg")
                                    .foregroundColor(weightDiff >= 0 ? .red : .green)
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("Bel Değişimi")
                                Spacer()
                                let waistDiff = waist - previous.waist
                                Text("\(waistDiff >= 0 ? "+" : "")\(String(format: "%.1f", waistDiff)) cm")
                                    .foregroundColor(waistDiff >= 0 ? .red : .green)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
                
                Section("Hesaplanan Değerler") {
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
                            Text("VKİ")
                            Spacer()
                            Text(String(format: "%.1f", bodyMetrics.bmi))
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Vücut Yağ Oranı")
                            Spacer()
                            Text(String(format: "%.1f%%", bodyMetrics.bodyFatPercentage))
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Bel-Kalça Oranı")
                            Spacer()
                            Text(String(format: "%.2f", bodyMetrics.waistToHipRatio))
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .navigationTitle("Yeni Ölçüm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        saveMeasurement()
                    }
                    .disabled(isLoading)
                }
            }
            .task {
                await loadInitialData()
            }
            .alert("Hata", isPresented: .constant(errorMessage != nil)) {
                Button("Tamam") {
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
                print("DEBUG: Yeni ölçüm başarıyla kaydedildi")
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Ölçüm kaydedilirken hata oluştu: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    AddMeasurementView(userId: UUID())
}
