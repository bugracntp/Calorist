import SwiftUI

// Import entities and components from Domain and Presentation layers
// Note: In a real project, you might need to adjust the import paths
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var showingAddMeasurement = false
    @State private var showingThemeSettings = false
    @State private var showingDailyCalories = false
    @State private var showingBodyMetrics = false
    @State private var showingActivitySettings = false
    @State private var animateCards = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        themeManager.isDarkMode ? Color.black.opacity(0.8) : Color.blue.opacity(0.1),
                        themeManager.isDarkMode ? Color.purple.opacity(0.3) : Color.purple.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if let user = viewModel.user, let bodyMetrics = viewModel.bodyMetrics {
                            // Unified user info and metrics card
                            UnifiedUserInfoCard(
                                user: user,
                                bodyMetrics: bodyMetrics,
                                onCaloriesTap: { showingDailyCalories = true },
                                onMetricsTap: { showingBodyMetrics = true },
                                onThemeToggle: { showingThemeSettings = true }
                            )
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 50)
                            

                            
                            // Quick actions
                            QuickActionsView(
                                onAddMeasurement: { showingAddMeasurement = true },
                                onActivitySettings: { showingActivitySettings = true }
                            )
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 50)
                            
                        } else {
                            // User setup view
                            UserSetupView { user, initialMeasurement in
                                print("DEBUG: UserSetupView callback çağrıldı")
                                Task { @MainActor in
                                    await viewModel.saveUser(user, withInitialMeasurement: initialMeasurement)
                                    print("DEBUG: Kullanıcı kaydedildi, user: \(viewModel.user?.name ?? "nil")")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle(localizationManager.localizedString("app_name"))
            .navigationBarTitleDisplayMode(.large)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddMeasurement) {
                if let user = viewModel.user {
                    AddMeasurementView(userId: user.id)
                }
            }
            .sheet(isPresented: $showingThemeSettings) {
                ThemeSettingsView()
            }
            .sheet(isPresented: $showingDailyCalories) {
                if let user = viewModel.user, let bodyMetrics = viewModel.bodyMetrics {
                    DailyCaloriesView(
                        dailyCalories: viewModel.dailyCalories,
                        bmi: bodyMetrics.bmi,
                        bodyFatPercentage: bodyMetrics.bodyFatPercentage
                    )
                }
            }
            .sheet(isPresented: $showingBodyMetrics) {
                if let bodyMetrics = viewModel.bodyMetrics {
                    BodyMetricsView(bodyMetrics: bodyMetrics)
                }
            }
            .sheet(isPresented: $showingActivitySettings) {
                if let user = viewModel.user, let bodyMetrics = viewModel.bodyMetrics {
                    ActivitySettingsCard(
                        user: user,
                        bodyMetrics: bodyMetrics,
                        onSave: { updatedUser in
                            Task {
                                await viewModel.updateUser(updatedUser)
                            }
                        }
                    )
                    .environmentObject(themeManager)
                }
            }
            .alert("Hata", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("Tamam") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .task {
            print("DEBUG: HomeView task başladı")
            await viewModel.loadUserData()
            print("DEBUG: loadUserData tamamlandı, user: \(viewModel.user?.name ?? "nil")")
            
            // Animate cards on appear
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animateCards = true
            }
        }
    }
}



struct ModernUserInfoCard: View {
    let user: User
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    // Animated avatar
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "person.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("\(Int(user.age)) yaş • \(user.gender.displayName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .background(Color.primary.opacity(0.1))
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Vücut ölçüleri")
                            .font(.headline)
                        Text("Ölçüm ekranından görüntüleyin")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Güncel")
                            .font(.headline)
                        Text("Son ölçüm tarihi")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct ModernBodyMetricsCard: View {
    let bodyMetrics: BodyMetrics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Vücut Metrikleri")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ModernMetricItem(
                    title: "VKİ",
                    value: String(format: "%.1f", bodyMetrics.bmi),
                    category: CalorieCalculator.getBMICategory(bmi: bodyMetrics.bmi),
                    color: getBMIColor(bmi: bodyMetrics.bmi)
                )
                
                ModernMetricItem(
                    title: "Yağ Oranı",
                    value: String(format: "%.1f%%", bodyMetrics.bodyFatPercentage),
                    category: getBodyFatCategory(bodyMetrics.bodyFatPercentage),
                    color: getBodyFatColor(bodyMetrics.bodyFatPercentage)
                )
                
                ModernMetricItem(
                    title: "Bel-Kalça",
                    value: String(format: "%.2f", bodyMetrics.waistToHipRatio),
                    category: getWaistToHipCategory(bodyMetrics.waistToHipRatio),
                    color: getWaistToHipColor(bodyMetrics.waistToHipRatio)
                )
                
                ModernMetricItem(
                    title: "İdeal Kilo",
                    value: String(format: "%.1f kg", bodyMetrics.idealWeight),
                    category: "Hedef",
                    color: .green
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.primary.opacity(0.1), Color.primary.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(radius: 8)
    }
    
    private func getBMIColor(bmi: Double) -> Color {
        switch bmi {
        case ..<18.5: return .blue
        case 18.5..<25: return .green
        case 25..<30: return .orange
        case 30..<35: return .red
        case 35..<40: return .purple
        default: return .black
        }
    }
    
    private func getBodyFatColor(_ percentage: Double) -> Color {
        if percentage < 10 { return .blue }
        else if percentage < 20 { return .green }
        else if percentage < 30 { return .orange }
        else if percentage < 40 { return .red }
        else { return .purple }
    }
    
    private func getWaistToHipColor(_ ratio: Double) -> Color {
        if ratio < 0.8 { return .green }
        else if ratio < 0.85 { return .orange }
        else { return .red }
    }
    
    private func getBodyFatCategory(_ percentage: Double) -> String {
        if percentage < 10 { return "Çok Düşük" }
        else if percentage < 20 { return "Düşük" }
        else if percentage < 30 { return "Normal" }
        else if percentage < 40 { return "Yüksek" }
        else { return "Çok Yüksek" }
    }
    
    private func getWaistToHipCategory(_ ratio: Double) -> String {
        if ratio < 0.8 { return "Düşük Risk" }
        else if ratio < 0.85 { return "Orta Risk" }
        else { return "Yüksek Risk" }
    }
}

struct ModernMetricItem: View {
    let title: String
    let value: String
    let category: String
    let color: Color
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(category)
                .font(.caption2)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(color.opacity(0.2))
                )
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.3), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
    }
}

struct QuickActionsView: View {
    let onAddMeasurement: () -> Void
    let onActivitySettings: () -> Void
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text(localizationManager.localizedString("quick_actions"))
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            AnimatedGradientButton(
                title: localizationManager.localizedString("add_measurement"),
                icon: "plus.circle.fill"
            ) {
                onAddMeasurement()
            }
            
            // Aktivite ayarları butonu
            Button(action: onActivitySettings) {
                HStack(spacing: 12) {
                    Image(systemName: "figure.walk")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text(localizationManager.localizedString("activity_settings"))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: Color.orange.opacity(0.3),
                    radius: 15,
                    x: 0,
                    y: 8
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(ThemeManager())
        .environmentObject(LocalizationManager.shared)
}
