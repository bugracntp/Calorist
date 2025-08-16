import SwiftUI

struct ActivitySettingsCard: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    let user: User
    let bodyMetrics: BodyMetrics?
    let onSave: (User) -> Void
    
    @State private var selectedActivityLevel: ActivityLevel
    @State private var selectedGoal: Goal
    @State private var showingSaveAlert = false
    
    init(user: User, bodyMetrics: BodyMetrics?, onSave: @escaping (User) -> Void) {
        self.user = user
        self.bodyMetrics = bodyMetrics
        self.onSave = onSave
        self._selectedActivityLevel = State(initialValue: user.activityLevel)
        self._selectedGoal = State(initialValue: user.goal)
    }
    
    var body: some View {
        ModernCard {
            VStack(spacing: 20) {
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
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "figure.walk")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(localizationManager.localizedString("activity_settings"))
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(localizationManager.localizedString("activity_settings_description"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .background(Color.primary.opacity(0.1))
                
                // Activity Level Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text(localizationManager.localizedString("activity_level"))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            ActivityLevelButton(
                                level: level,
                                isSelected: selectedActivityLevel == level,
                                onTap: { selectedActivityLevel = level }
                            )
                        }
                    }
                }
                
                Divider()
                    .background(Color.primary.opacity(0.1))
                
                // Goal Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text(localizationManager.localizedString("goal"))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        ForEach(Goal.allCases, id: \.self) { goal in
                            GoalButton(
                                goal: goal,
                                isSelected: selectedGoal == goal,
                                onTap: { selectedGoal = goal }
                            )
                        }
                    }
                }
                
                Divider()
                    .background(Color.primary.opacity(0.1))
                
                // Current Settings Info
                VStack(spacing: 12) {
                    HStack {
                        Text(localizationManager.localizedString("current_multiplier"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(String(format: "%.2f", selectedActivityLevel.multiplier))x")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                    
                    HStack {
                        Text(localizationManager.localizedString("daily_calories"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(calculateDailyCalories())) kcal")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
                
                // Save Button
                Button(action: saveSettings) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                        
                        Text(localizationManager.localizedString("save"))
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .alert(localizationManager.localizedString("settings_saved"), isPresented: $showingSaveAlert) {
            Button(localizationManager.localizedString("ok")) { }
        } message: {
            Text(localizationManager.localizedString("activity_level_and_goal_updated"))
        }
    }
    
    private func calculateDailyCalories() -> Double {
        // Eğer bodyMetrics varsa, ondan al, yoksa varsayılan değerler kullan
        guard let bodyMetrics = bodyMetrics else {
            // Varsayılan değerler (ortalama)
            let defaultWeight = 70.0
            let defaultHeight = 170.0
            let age = Double(user.age)
            
            let bmr: Double
            if user.gender == .male {
                bmr = (10 * defaultWeight) + (6.25 * defaultHeight) - (5 * age) + 5
            } else {
                bmr = (10 * defaultWeight) + (6.25 * defaultHeight) - (5 * age) - 161
            }
            
            return bmr * selectedActivityLevel.multiplier
        }
        
        // BodyMetrics'ten al
        return bodyMetrics.dailyCalorieNeeds * (selectedActivityLevel.multiplier / user.activityLevel.multiplier)
    }
    
    private func saveSettings() {
        let updatedUser = User(
            id: user.id,
            name: user.name,
            age: user.age,
            gender: user.gender,
            activityLevel: selectedActivityLevel,
            goal: selectedGoal,
            createdAt: user.createdAt,
            updatedAt: Date()
        )
        
        onSave(updatedUser)
        showingSaveAlert = true
    }
}

struct ActivityLevelButton: View {
    let level: ActivityLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: getIcon(for: level))
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(level.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text("\(String(format: "%.2f", level.multiplier))x")
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.primary.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getIcon(for level: ActivityLevel) -> String {
        switch level {
        case .sedentary: return "bed.double.fill"
        case .lightlyActive: return "figure.walk"
        case .moderatelyActive: return "figure.run"
        case .veryActive: return "figure.hiking"
        case .extremelyActive: return "figure.climbing"
        }
    }
}

struct GoalButton: View {
    let goal: Goal
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: getIcon(for: goal))
                    .font(.title3)
                
                Text(goal.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.green : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.green : Color.primary.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getIcon(for goal: Goal) -> String {
        switch goal {
        case .loseWeight: return "arrow.down.circle.fill"
        case .maintainWeight: return "equal.circle.fill"
        case .gainWeight: return "arrow.up.circle.fill"
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
    
    ActivitySettingsCard(user: user, bodyMetrics: bodyMetrics, onSave: { updatedUser in
        print("User updated: \(updatedUser.activityLevel.displayName)")
    })
    .environmentObject(ThemeManager())
    .padding()
}
