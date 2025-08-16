import SwiftUI

struct DailyTrackingTabView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var viewModel: DailyTrackingViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    init() {
        // Initialize with a temporary UUID, will be updated when user loads
        let tempViewModel = DailyTrackingViewModel(
            repository: DailyTrackingRepositoryImpl(coreDataManager: CoreDataManager.shared),
            userId: UUID()
        )
        self._viewModel = StateObject(wrappedValue: tempViewModel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient - matching other views
                LinearGradient(
                    colors: [
                        themeManager.isDarkMode ? Color.black.opacity(0.8) : Color.green.opacity(0.1),
                        themeManager.isDarkMode ? Color.green.opacity(0.3) : Color.green.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if homeViewModel.isLoading {
                    loadingView
                } else if let user = homeViewModel.user {
                    mainContentView
                } else {
                    noUserView
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            loadUserData()
        }
        .onChange(of: homeViewModel.user) { _, newUser in
            if let user = newUser {
                // Update the viewModel with the correct userId
                viewModel.updateUserId(user.id)
            }
        }
        .alert(localizationManager.localizedString("success"), isPresented: $viewModel.showingSaveAlert) {
            Button(localizationManager.localizedString("ok")) {
                viewModel.showingSaveAlert = false
            }
        } message: {
            Text(localizationManager.localizedString("tracking_saved"))
        }
        .alert("Hata", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("Tamam") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.green)
            
            Text("Veriler yükleniyor...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    private var noUserView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon with background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "person.crop.circle.badge.exclamationmark")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                Text("Kullanıcı Bilgisi Bulunamadı")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Lütfen ana ekrandan kullanıcı bilgilerinizi girin")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
    }
    
    private var mainContentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Section
                headerSection
                
                // Daily Progress Section
                dailyProgressSection
                
                // Input Section
                inputSection
                
                // Calorie Comparison Section
                calorieComparisonSection
                
                // Weekly Overview Section
                weeklyOverviewSection
                
                // Save Button
                saveButton
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 24) {
            // Title and subtitle with better typography
            VStack(spacing: 12) {
                Text(localizationManager.localizedString("daily_tracking"))
                    .font(.system(size: 28, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(localizationManager.localizedString("track_your_daily_intake"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            // Subtle date picker with minimal styling
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                    .font(.body)
                
                DatePicker("", selection: $viewModel.selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .onChange(of: viewModel.selectedDate) { _, newDate in
                        viewModel.changeDate(newDate)
                    }
                    .accentColor(.green)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6).opacity(0.5))
            )
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.systemBackground),
                            Color(.systemGray6).opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 3)
        )
    }
    
    private var dailyProgressSection: some View {
        VStack(spacing: 20) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(localizationManager.localizedString("today_progress"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(viewModel.selectedDate, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Progress indicator
                ZStack {
                    Circle()
                        .stroke(Color.green.opacity(0.2), lineWidth: 4)
                        .frame(width: 40, height: 40)
                    
                    Circle()
                        .trim(from: 0, to: min(1.0, (viewModel.currentTracking?.calorieIntake ?? 0) / (viewModel.trackingGoals?.dailyCalorieGoal ?? 2000)))
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: viewModel.currentTracking?.calorieIntake ?? 0)
                }
            }
            
            // Progress cards
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ProgressCard(
                    title: localizationManager.localizedString("calories"),
                    currentValue: viewModel.currentTracking?.calorieIntake ?? 0,
                    goalValue: viewModel.trackingGoals?.dailyCalorieGoal ?? 2000,
                    unit: "kcal",
                    progress: viewModel.getProgressPercentage(for: .calories),
                    color: .orange,
                    icon: "flame.fill"
                )
                
                ProgressCard(
                    title: localizationManager.localizedString("water"),
                    currentValue: viewModel.currentTracking?.waterIntake ?? 0,
                    goalValue: viewModel.trackingGoals?.dailyWaterGoal ?? 2.5,
                    unit: "L",
                    progress: viewModel.getProgressPercentage(for: .water),
                    color: .blue,
                    icon: "drop.fill"
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.systemBackground),
                            Color(.systemGray6).opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var inputSection: some View {
        VStack(spacing: 20) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(localizationManager.localizedString("add_today"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Günlük alımınızı kaydedin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
            
            // Input fields
            VStack(spacing: 16) {
                InputField(
                    title: localizationManager.localizedString("calories"),
                    value: $viewModel.calorieIntake,
                    placeholder: "0",
                    unit: "kcal",
                    icon: "flame.fill",
                    color: .orange
                )
                
                InputField(
                    title: localizationManager.localizedString("water"),
                    value: $viewModel.waterIntake,
                    placeholder: "0.0",
                    unit: "L",
                    icon: "drop.fill",
                    color: .blue
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.systemBackground),
                            Color(.systemGray6).opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var weeklyOverviewSection: some View {
        VStack(spacing: 20) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(localizationManager.localizedString("weekly_overview"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Bu haftaki ortalamalarınız")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(.purple)
            }
            
            // Weekly stats
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                WeeklyStatCard(
                    title: localizationManager.localizedString("avg_calories"),
                    value: String(format: "%.0f", viewModel.weeklyAverageCalories),
                    unit: "kcal",
                    color: .orange,
                    icon: "flame.fill"
                )
                
                WeeklyStatCard(
                    title: localizationManager.localizedString("avg_water"),
                    value: String(format: "%.1f", viewModel.weeklyAverageWater),
                    unit: "L",
                    color: .blue,
                    icon: "drop.fill"
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.systemBackground),
                            Color(.systemGray6).opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var calorieComparisonSection: some View {
        VStack(spacing: 20) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Kalori Karşılaştırması")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Günlük ihtiyaç vs alınan kaloriler")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chart.bar.xaxis")
                    .font(.title2)
                    .foregroundColor(.orange)
            }
            
            // Calorie comparison chart
            VStack(spacing: 16) {
                // Today's comparison
                VStack(spacing: 12) {
                    HStack {
                        Text("Bugün")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(Int(viewModel.currentTracking?.calorieIntake ?? 0)) / \(Int(viewModel.trackingGoals?.dailyCalorieGoal ?? 2000)) kcal")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    // Progress bar with comparison
                    VStack(spacing: 8) {
                        // Goal line
                        HStack {
                            Text("Hedef")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(Int(viewModel.trackingGoals?.dailyCalorieGoal ?? 2000)) kcal")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                        
                        // Main progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 20)
                                
                                // Goal indicator line
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(width: 2, height: 20)
                                    .offset(x: geometry.size.width * 0.8) // Assuming 2000 kcal is 80% of max
                                
                                // Consumed calories bar
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange, .red],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: min(
                                            geometry.size.width * viewModel.getProgressPercentage(for: .calories),
                                            geometry.size.width
                                        ),
                                        height: 20
                                    )
                                    .animation(.easeInOut(duration: 1.0), value: viewModel.currentTracking?.calorieIntake ?? 0)
                            }
                        }
                        .frame(height: 20)
                        
                        // Consumed calories label
                        HStack {
                            Text("Alınan")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(Int(viewModel.currentTracking?.calorieIntake ?? 0)) kcal")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Divider()
                    .background(Color(.systemGray4))
                
                // Weekly comparison
                VStack(spacing: 12) {
                    HStack {
                        Text("Bu Hafta")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("Ortalama: \(Int(viewModel.weeklyAverageCalories)) kcal")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    // Weekly mini chart
                    HStack(spacing: 4) {
                        ForEach(0..<7) { index in
                            let dayProgress = getDayProgress(for: index)
                            
                            VStack(spacing: 4) {
                                // Day bar
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(
                                        dayProgress > 0.8 ? Color.red :
                                        dayProgress > 0.6 ? Color.orange :
                                        dayProgress > 0.4 ? Color.yellow :
                                        dayProgress > 0.2 ? Color.blue :
                                        Color(.systemGray4)
                                    )
                                    .frame(
                                        width: 20,
                                        height: 40 * dayProgress
                                    )
                                    .animation(.easeInOut(duration: 0.5), value: dayProgress)
                                
                                // Day label
                                Text(getDayLabel(for: index))
                                    .font(.caption2)
                                    .foregroundColor(
                                        isCurrentDay(index: index) ? .green : .secondary
                                    )
                                    .fontWeight(
                                        isCurrentDay(index: index) ? .bold : .regular
                                    )
                            }
                        }
                    }
                    .frame(height: 60)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.systemBackground),
                            Color(.systemGray6).opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var saveButton: some View {
        Button(action: saveTracking) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                
                Text(localizationManager.localizedString("save"))
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [.green, .teal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
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
                color: Color.green.opacity(0.4),
                radius: 20,
                x: 0,
                y: 10
            )
        }
        .padding(.horizontal, 20)
    }
    
    private func loadUserData() {
        Task {
            await homeViewModel.loadUserData()
        }
    }
    
    private func saveTracking() {
        Task {
            await viewModel.saveTracking()
        }
    }
    
    // MARK: - Helper Functions
    
    private func getDayProgress(for index: Int) -> Double {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        guard let targetDate = calendar.date(byAdding: .day, value: index, to: startOfWeek) else {
            return 0.0
        }
        
        // Find tracking data for this specific day
        if let weeklyData = viewModel.weeklyTracking.first(where: { tracking in
            calendar.isDate(tracking.date, inSameDayAs: targetDate)
        }) {
            let goal = viewModel.trackingGoals?.dailyCalorieGoal ?? 2000
            return min(weeklyData.calorieIntake / goal, 1.0)
        }
        
        return 0.0
    }
    
    private func getDayLabel(for index: Int) -> String {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        guard let targetDate = calendar.date(byAdding: .day, value: index, to: startOfWeek) else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "E"
        
        return formatter.string(from: targetDate).prefix(1).uppercased()
    }
    
    private func isCurrentDay(index: Int) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        guard let targetDate = calendar.date(byAdding: .day, value: index, to: startOfWeek) else {
            return false
        }
        
        return calendar.isDate(targetDate, inSameDayAs: today)
    }
}

#Preview {
    DailyTrackingTabView()
        .environmentObject(ThemeManager())
        .environmentObject(LocalizationManager.shared)
}
