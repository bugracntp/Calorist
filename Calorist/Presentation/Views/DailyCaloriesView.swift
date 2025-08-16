import SwiftUI

struct DailyCaloriesView: View {
    let dailyCalories: Double
    let bmi: Double
    let bodyFatPercentage: Double
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var localizationManager: LocalizationManager
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
                                        Text(localizationManager.localizedString("daily_calories_title"))
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        
                                        Text(localizationManager.localizedString("daily_calories_subtitle"))
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
                                    
                                    Text(localizationManager.localizedString("daily_calories_unit"))
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
                                        
                                        Text(localizationManager.localizedString("target"))
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
                                        Text(localizationManager.localizedString("bmi"))
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
                                        Text(localizationManager.localizedString("body_fat"))
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
            .navigationTitle(localizationManager.localizedString("daily_calories_title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localizationManager.localizedString("close")) {
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
        case ..<18.5: return localizationManager.localizedString("underweight")
        case 18.5..<25: return localizationManager.localizedString("normal")
        case 25..<30: return localizationManager.localizedString("overweight")
        case 30..<35: return localizationManager.localizedString("obese")
        default: return localizationManager.localizedString("extremely_obese")
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
        case ..<10: return localizationManager.localizedString("very_low")
        case 10..<20: return localizationManager.localizedString("low")
        case 20..<30: return localizationManager.localizedString("normal")
        case 30..<40: return localizationManager.localizedString("high")
        default: return localizationManager.localizedString("very_high")
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
