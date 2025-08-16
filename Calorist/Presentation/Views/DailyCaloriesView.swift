import SwiftUI

struct DailyCaloriesView: View {
    let dailyCalories: Double
    let bmi: Double
    let bodyFatPercentage: Double
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State private var animateValues = false
    @State private var showProgressRing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        themeManager.isDarkMode ? Color.black.opacity(0.8) : Color.orange.opacity(0.1),
                        themeManager.isDarkMode ? Color.orange.opacity(0.3) : Color.red.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Main calorie display
                        ModernCard {
                            VStack(spacing: 24) {
                                // Header
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [.orange, .red],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 60, height: 60)
                                        
                                        Image(systemName: "flame.fill")
                                            .font(.title)
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Günlük Kalori İhtiyacı")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        
                                        Text("BMR + Aktivite Faktörü")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                
                                // Large calorie display
                                VStack(spacing: 16) {
                                    Text("\(Int(dailyCalories))")
                                        .font(.system(size: 72, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                        .opacity(animateValues ? 1 : 0)
                                        .offset(y: animateValues ? 0 : 30)
                                        .scaleEffect(animateValues ? 1 : 0.8)
                                    
                                    Text("kalori/gün")
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                        .opacity(animateValues ? 1 : 0)
                                        .offset(y: animateValues ? 0 : 20)
                                }
                                .frame(maxWidth: .infinity)
                                
                                // Progress ring
                                ZStack {
                                    Circle()
                                        .stroke(Color.orange.opacity(0.2), lineWidth: 12)
                                        .frame(width: 120, height: 120)
                                    
                                    Circle()
                                        .trim(from: 0, to: showProgressRing ? 0.8 : 0)
                                        .stroke(
                                            LinearGradient(
                                                colors: [.orange, .red],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                        )
                                        .frame(width: 120, height: 120)
                                        .rotationEffect(.degrees(-90))
                                        .animation(.easeInOut(duration: 1.5), value: showProgressRing)
                                    
                                    VStack(spacing: 4) {
                                        Text("80%")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.orange)
                                        
                                        Text("Hedef")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        
                        // Additional info cards
                        VStack(spacing: 16) {
                            // BMI Info
                            ModernCard {
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [.blue, .purple],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "chart.bar.fill")
                                            .font(.title3)
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Vücut Kitle İndeksi")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        
                                        Text("\(String(format: "%.1f", bmi))")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(getBMIColor(bmi: bmi))
                                    }
                                    
                                    Spacer()
                                    
                                    Text(getBMICategory(bmi: bmi))
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(getBMIColor(bmi: bmi).opacity(0.2))
                                        )
                                        .foregroundColor(getBMIColor(bmi: bmi))
                                }
                            }
                            
                            // Body Fat Info
                            ModernCard {
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [.green, .teal],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "drop.fill")
                                            .font(.title3)
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Vücut Yağ Oranı")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        
                                        Text("\(String(format: "%.1f", bodyFatPercentage))%")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(getBodyFatColor(bodyFatPercentage))
                                    }
                                    
                                    Spacer()
                                    
                                    Text(getBodyFatCategory(bodyFatPercentage))
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(getBodyFatColor(bodyFatPercentage).opacity(0.2))
                                        )
                                        .foregroundColor(getBodyFatColor(bodyFatPercentage))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Günlük Kalori")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
        .environmentObject(themeManager)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animateValues = true
            }
            
            withAnimation(.easeOut(duration: 1.0).delay(0.8)) {
                showProgressRing = true
            }
        }
    }
    
    private func getBMIColor(bmi: Double) -> Color {
        switch bmi {
        case ..<18.5: return .blue
        case 18.5..<25: return .green
        case 25..<30: return .orange
        case 30..<35: return .red
        default: return .purple
        }
    }
    
    private func getBMICategory(bmi: Double) -> String {
        switch bmi {
        case ..<18.5: return "Zayıf"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Fazla Kilolu"
        case 30..<35: return "Obez"
        default: return "Aşırı Obez"
        }
    }
    
    private func getBodyFatColor(_ percentage: Double) -> Color {
        switch percentage {
        case ..<10: return .blue
        case 10..<20: return .green
        case 20..<30: return .orange
        case 30..<40: return .red
        default: return .purple
        }
    }
    
    private func getBodyFatCategory(_ percentage: Double) -> String {
        switch percentage {
        case ..<10: return "Çok Düşük"
        case 10..<20: return "Düşük"
        case 20..<30: return "Normal"
        case 30..<40: return "Yüksek"
        default: return "Çok Yüksek"
        }
    }
}

#Preview {
    DailyCaloriesView(
        dailyCalories: 2200,
        bmi: 24.5,
        bodyFatPercentage: 18.5
    )
    .environmentObject(ThemeManager())
}
