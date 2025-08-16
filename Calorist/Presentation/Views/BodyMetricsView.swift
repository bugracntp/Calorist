import SwiftUI

struct BodyMetricsView: View {
    let bodyMetrics: BodyMetrics
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    @State private var animateMetrics = false
    @State private var showProgressRings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        themeManager.isDarkMode ? Color.black.opacity(0.8) : Color.green.opacity(0.1),
                        themeManager.isDarkMode ? Color.blue.opacity(0.3) : Color.blue.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Main metrics overview
                        ModernCard {
                            VStack(spacing: 20) {
                                // Header
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [.green, .blue],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 60, height: 60)
                                        
                                        Image(systemName: "figure.arms.open")
                                            .font(.title)
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(localizationManager.localizedString("body_metrics_title"))
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        
                                        Text(localizationManager.localizedString("body_metrics_subtitle"))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                
                                // Key metrics grid
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 16) {
                                    MetricItem(
                                        title: localizationManager.localizedString("ideal_weight"),
                                        value: "\(String(format: "%.1f", bodyMetrics.idealWeight)) kg",
                                        icon: "scalemass.fill",
                                        color: .blue,
                                        animate: animateMetrics
                                    )
                                    
                                    MetricItem(
                                        title: localizationManager.localizedString("bmi"),
                                        value: "\(String(format: "%.1f", bodyMetrics.bmi))",
                                        icon: "chart.bar.fill",
                                        color: .green,
                                        animate: animateMetrics
                                    )
                                    
                                    MetricItem(
                                        title: localizationManager.localizedString("waist_to_hip_ratio"),
                                        value: String(format: "%.2f", bodyMetrics.waistToHipRatio),
                                        icon: "chart.line.uptrend.xyaxis",
                                        color: .orange,
                                        animate: animateMetrics
                                    )
                                    
                                    MetricItem(
                                        title: localizationManager.localizedString("daily_calories"),
                                        value: "\(Int(bodyMetrics.dailyCalorieNeeds)) kcal",
                                        icon: "flame.fill",
                                        color: .purple,
                                        animate: animateMetrics
                                    )
                                }
                            }
                        }
                        
                        // Progress rings section
                        ModernCard {
                            VStack(spacing: 20) {
                                Text(localizationManager.localizedString("body_composition"))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack(spacing: 24) {
                                    // BMI Progress Ring
                                    VStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                                                .frame(width: 100, height: 100)
                                            
                                            Circle()
                                                .trim(from: 0, to: showProgressRings ? getBMICategoryProgress(bodyMetrics.bmi) : 0)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [.blue, .purple],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                                )
                                                .frame(width: 100, height: 100)
                                                .rotationEffect(.degrees(-90))
                                                .animation(.easeInOut(duration: 1.5), value: showProgressRings)
                                            
                                            VStack(spacing: 2) {
                                                Text("\(String(format: "%.1f", bodyMetrics.bmi))")
                                                    .font(.headline)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.blue)
                                                
                                                Text(localizationManager.localizedString("bmi"))
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        Text(getBMICategory(bodyMetrics.bmi))
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    // Body Fat Progress Ring
                                    VStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .stroke(Color.green.opacity(0.2), lineWidth: 8)
                                                .frame(width: 100, height: 100)
                                            
                                            Circle()
                                                .trim(from: 0, to: showProgressRings ? getBodyFatProgress(bodyMetrics.bodyFatPercentage) : 0)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [.green, .teal],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                                )
                                                .frame(width: 100, height: 100)
                                                .rotationEffect(.degrees(-90))
                                                .animation(.easeInOut(duration: 1.5), value: showProgressRings)
                                            
                                            VStack(spacing: 2) {
                                                Text("\(String(format: "%.1f", bodyMetrics.bodyFatPercentage))%")
                                                    .font(.headline)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.green)
                                                
                                                Text(localizationManager.localizedString("body_fat"))
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        Text(getBodyFatCategory(bodyMetrics.bodyFatPercentage))
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.green)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        
                        // Additional measurements
                        ModernCard {
                            VStack(spacing: 20) {
                                Text(localizationManager.localizedString("detailed_measurements"))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(spacing: 16) {
                                    MeasurementRow(
                                            title: localizationManager.localizedString("arm_circumference"),
                                        value: "\(String(format: "%.1f", bodyMetrics.armCircumference)) cm",
                                        icon: "circle.dashed",
                                        color: .orange,
                                        animate: animateMetrics
                                    )
                                    
                                    Divider()
                                        .background(Color.primary.opacity(0.1))
                                    
                                    MeasurementRow(
                                        title: localizationManager.localizedString("neck_circumference"),
                                        value: "\(String(format: "%.1f", bodyMetrics.armCircumference)) cm",
                                        icon: "circle.dashed",
                                        color: .purple,
                                        animate: animateMetrics
                                    )
                                    
                                    Divider()
                                        .background(Color.primary.opacity(0.1))
                                    
                                    MeasurementRow(
                                        title: localizationManager.localizedString("waist_to_hip_ratio"),
                                        value: String(format: "%.2f", bodyMetrics.waistToHipRatio),
                                        icon: "chart.bar.fill",
                                        color: .teal,
                                        animate: animateMetrics
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle(localizationManager.localizedString("body_metrics_title"))
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
                animateMetrics = true
            }
            
            withAnimation(.easeOut(duration: 1.0).delay(0.8)) {
                showProgressRings = true
            }
        }
    }
    
    private func getBMICategoryProgress(_ bmi: Double) -> Double {
        if bmi < 18.5 { return 0.2 }
        else if bmi < 25 { return 0.5 }
        else if bmi < 30 { return 0.7 }
        else if bmi < 35 { return 0.85 }
        else { return 1.0 }
    }
    
    private func getBodyFatProgress(_ percentage: Double) -> Double {
        if percentage < 10 { return 0.2 }
        else if percentage < 20 { return 0.4 }
        else if percentage < 30 { return 0.6 }
        else if percentage < 40 { return 0.8 }
        else { return 1.0 }
    }
    
    private func getBMICategory(_ bmi: Double) -> String {
        switch bmi {
        case ..<18.5: return localizationManager.localizedString("underweight")
        case 18.5..<25: return localizationManager.localizedString("normal")
        case 25..<30: return localizationManager.localizedString("overweight")
        case 30..<35: return localizationManager.localizedString("obese")
        default: return localizationManager.localizedString("extremely_obese")
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

struct MetricItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let animate: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .opacity(animate ? 1 : 0)
        .offset(y: animate ? 0 : 20)
        .animation(.easeOut(duration: 0.6).delay(0.1), value: animate)
    }
}

struct MeasurementRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let animate: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .opacity(animate ? 1 : 0)
        .offset(x: animate ? 0 : -20)
        .animation(.easeOut(duration: 0.6).delay(0.2), value: animate)
    }
}

#Preview {
    let user = User(
        name: "Bugra",
        age: 24,
        gender: .male,
        activityLevel: .moderatelyActive,
        goal: .maintainWeight
    )
    
    let measurement = Measurement(
        userId: user.id,
        height: 175.0,
        weight: 75.0,
        neck: 35.0,
        waist: 80.0,
        hip: 95.0,
        arm: 30.0
    )
    
    let bodyMetrics = BodyMetrics(measurement: measurement, user: user)
    
    return BodyMetricsView(bodyMetrics: bodyMetrics)
        .environmentObject(ThemeManager())
}
