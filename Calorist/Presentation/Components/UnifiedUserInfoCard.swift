import SwiftUI

struct UnifiedUserInfoCard: View {
    let user: User
    let bodyMetrics: BodyMetrics
    let onCaloriesTap: () -> Void
    let onMetricsTap: () -> Void
    let onThemeToggle: () -> Void
    
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var animateCard = false
    
    var body: some View {
        ModernCard {
            VStack(spacing: 24) {
                // User Info Section
                HStack(spacing: 20) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                    
                    // User Details
                    VStack(alignment: .leading, spacing: 8) {
                        Text(user.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("\(user.age) \(localizationManager.localizedString("years")) • \(user.gender == .male ? localizationManager.localizedString("male") : localizationManager.localizedString("female"))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Quick stats
                        HStack(spacing: 16) {
                            VStack(spacing: 2) {
                                Text("\(String(format: "%.1f", bodyMetrics.idealWeight))")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                
                                Text(localizationManager.localizedString("ideal_weight"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 2) {
                                Text("\(String(format: "%.1f", bodyMetrics.bmi))")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                
                                Text(localizationManager.localizedString("bmi"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Theme toggle button
                    Button(action: onThemeToggle) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "moon.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Divider()
                    .background(Color.primary.opacity(0.1))
                
                // Interactive Sections
                VStack(spacing: 16) {
                    // Daily Calories Section
                    Button(action: onCaloriesTap) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange, .red],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "flame.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(localizationManager.localizedString("daily_calories"))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text(localizationManager.localizedString("view_from_measurement"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(localizationManager.localizedString("current"))
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.orange)
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Body Metrics Section
                    Button(action: onMetricsTap) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.green, .blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "figure.arms.open")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(localizationManager.localizedString("body_metrics"))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text(localizationManager.localizedString("view_from_measurement"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(localizationManager.localizedString("current"))
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.green)
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .opacity(animateCard ? 1 : 0)
        .offset(y: animateCard ? 0 : 30)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.1)) {
                animateCard = true
            }
        }
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
    
    return UnifiedUserInfoCard(
        user: user,
        bodyMetrics: bodyMetrics,
        onCaloriesTap: {},
        onMetricsTap: {},
        onThemeToggle: {}
    )
    .environmentObject(ThemeManager())
    .environmentObject(LocalizationManager.shared)
    .padding()
}
