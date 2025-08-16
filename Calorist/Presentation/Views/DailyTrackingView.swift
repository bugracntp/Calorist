import SwiftUI

struct DailyTrackingView: View {
    @StateObject private var viewModel: DailyTrackingViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    
    init(userId: UUID) {
        let repository = DailyTrackingRepositoryImpl(coreDataManager: CoreDataManager.shared)
        self._viewModel = StateObject(wrappedValue: DailyTrackingViewModel(repository: repository, userId: userId))
    }
    
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
                        // Header with date picker
                        dateHeaderSection
                        
                        // Daily progress cards
                        dailyProgressSection
                        
                        // Input section
                        inputSection
                        
                        // Weekly overview
                        weeklyOverviewSection
                        
                        // Save button
                        saveButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle(localizationManager.localizedString("daily_tracking"))
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
        .alert(localizationManager.localizedString("success"), isPresented: $viewModel.showingSaveAlert) {
            Button(localizationManager.localizedString("ok")) { }
        } message: {
            Text(localizationManager.localizedString("tracking_saved"))
        }
        .alert("Hata", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("Tamam") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    private var dateHeaderSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(localizationManager.localizedString("today"))
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(DateFormatter.dayFormatter.string(from: viewModel.selectedDate))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                DatePicker("", selection: $viewModel.selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .onChange(of: viewModel.selectedDate) { _, newDate in
                        viewModel.changeDate(newDate)
                    }
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
    
    private var dailyProgressSection: some View {
        HStack(spacing: 16) {
            // Calorie progress card
            ProgressCard(
                title: localizationManager.localizedString("calories"),
                currentValue: viewModel.currentTracking?.calorieIntake ?? 0,
                goalValue: viewModel.trackingGoals?.dailyCalorieGoal ?? 2000,
                unit: "kcal",
                progress: viewModel.getProgressPercentage(for: .calories),
                color: .orange,
                icon: "flame.fill"
            )
            
            // Water progress card
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
    
    private var inputSection: some View {
        VStack(spacing: 20) {
            Text(localizationManager.localizedString("add_today"))
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 16) {
                // Calorie input
                InputField(
                    title: localizationManager.localizedString("calories"),
                    value: $viewModel.calorieIntake,
                    placeholder: "2000",
                    unit: "kcal",
                    icon: "flame.fill",
                    color: .orange
                )
                
                // Water input
                InputField(
                    title: localizationManager.localizedString("water"),
                    value: $viewModel.waterIntake,
                    placeholder: "2.5",
                    unit: "L",
                    icon: "drop.fill",
                    color: .blue
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
    
    private var weeklyOverviewSection: some View {
        VStack(spacing: 16) {
            Text(localizationManager.localizedString("weekly_overview"))
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                WeeklyStatCard(
                    title: localizationManager.localizedString("avg_calories"),
                    value: String(format: "%.0f", viewModel.getWeeklyAverage(for: .calories)),
                    unit: "kcal",
                    color: .orange,
                    icon: "flame.fill"
                )
                
                WeeklyStatCard(
                    title: localizationManager.localizedString("avg_water"),
                    value: String(format: "%.1f", viewModel.getWeeklyAverage(for: .water)),
                    unit: "L",
                    color: .blue,
                    icon: "drop.fill"
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
    
    private var saveButton: some View {
        Button(action: {
            Task {
                await viewModel.saveTracking()
            }
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                }
                
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
        .disabled(viewModel.isLoading)
    }
}

// MARK: - Supporting Views

struct ProgressCard: View {
    let title: String
    let currentValue: Double
    let goalValue: Double
    let unit: String
    let progress: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 8) {
                Text("\(Int(currentValue))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text("/ \(Int(goalValue)) \(unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(color.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct InputField: View {
    let title: String
    @Binding var value: String
    let placeholder: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                TextField(placeholder, text: $value)
                    .keyboardType(.decimalPad)
                    .font(.headline)
            }
            
            Spacer()
            
            Text(unit)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(0.05))
        )
    }
}

struct WeeklyStatCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter
    }()
}

#Preview {
    DailyTrackingView(userId: UUID())
        .environmentObject(ThemeManager())
        .environmentObject(LocalizationManager.shared)
}
