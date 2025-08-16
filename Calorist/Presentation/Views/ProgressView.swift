import SwiftUI
import Charts

// Import entities and components from Domain and Presentation layers
// Note: In a real project, you might need to adjust the import paths
struct ProgressView: View {
    @StateObject private var viewModel = ProgressViewModel()
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var showingAddMeasurement = false
    @State private var animateCharts = false
    @State private var selectedTimeRange: TimeRange = .month
    
    enum TimeRange: String, CaseIterable {
        case week = "week"
        case month = "month"
        case threeMonths = "three_months"
        case year = "year"
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            if viewModel.isLoading {
                LoadingView()
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        
                        if !viewModel.measurements.isEmpty {
                            weightProgressChart
                            progressSummarySection
                            measurementsList
                        } else {
                            emptyStateView
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .environmentObject(themeManager)
        .navigationTitle(localizationManager.localizedString("progress_title"))
        .navigationBarTitleDisplayMode(.large)
        .navigationBarHidden(true)
        .task {
            await viewModel.loadMeasurements()
            
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animateCharts = true
            }
        }
        .sheet(isPresented: $showingAddMeasurement) {
            if let user = viewModel.user {
                AddMeasurementView(userId: user.id)
            }
        }
        .alert(localizationManager.localizedString("error"), isPresented: .constant(viewModel.errorMessage != nil)) {
            Button(localizationManager.localizedString("ok")) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                themeManager.isDarkMode ? Color.black.opacity(0.8) : Color.green.opacity(0.1),
                themeManager.isDarkMode ? Color.blue.opacity(0.3) : Color.blue.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var headerSection: some View {
        HeaderSection(
            selectedTimeRange: $selectedTimeRange,
            onAddMeasurement: { showingAddMeasurement = true }
        )
        .opacity(animateCharts ? 1 : 0)
        .offset(y: animateCharts ? 0 : 50)
    }
    
    private var emptyStateView: some View {
        EmptyStateView()
            .opacity(animateCharts ? 1 : 0)
            .offset(y: animateCharts ? 0 : 50)
    }
    
    private var weightProgressChart: some View {
        ModernWeightProgressChart(
            measurements: viewModel.measurements,
            weightProgress: viewModel.getWeightProgress(),
            dates: viewModel.getDates(),
            timeRange: selectedTimeRange
        )
        .opacity(animateCharts ? 1 : 0)
        .offset(y: animateCharts ? 0 : 50)
    }
    
    private var progressSummarySection: some View {
        ProgressSummarySection(viewModel: viewModel)
            .opacity(animateCharts ? 1 : 0)
            .offset(y: animateCharts ? 0 : 50)
    }
    
    
    private var measurementsList: some View {
        ModernMeasurementsList(
            measurements: viewModel.measurements,
            onDelete: { measurement in
                Task {
                    await viewModel.deleteMeasurement(measurement)
                }
            }
        )
        .opacity(animateCharts ? 1 : 0)
        .offset(y: animateCharts ? 0 : 50)
    }
}

struct HeaderSection: View {
    @Binding var selectedTimeRange: ProgressView.TimeRange
    let onAddMeasurement: () -> Void
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(localizationManager.localizedString("progress_title"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(localizationManager.localizedString("progress_description"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                FloatingActionButton(icon: "plus") {
                    onAddMeasurement()
                }
            }
            
            // Time range selector
            HStack(spacing: 12) {
                ForEach(ProgressView.TimeRange.allCases, id: \.self) { range in
                    TimeRangeButton(
                        range: range,
                        isSelected: selectedTimeRange == range,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                selectedTimeRange = range
                            }
                        }
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
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
    }
}

struct ModernWeightProgressChart: View {
    let measurements: [Measurement]
    let weightProgress: [Double]
    let dates: [Date]
    let timeRange: ProgressView.TimeRange
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.blue)
                        .font(.title2)
                    
                    Text(localizationManager.localizedString("weight_progress"))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text(localizationManager.localizedString(timeRange.rawValue))
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(.blue.opacity(0.2))
                        )
                        .foregroundColor(.blue)
                }
                
                if #available(iOS 16.0, *) {
                    Chart {
                        ForEach(Array(zip(dates, weightProgress).enumerated()), id: \.offset) { index, data in
                            LineMark(
                                x: .value(localizationManager.localizedString("date"), data.0),
                                y: .value(localizationManager.localizedString("weight"), data.1)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .lineStyle(StrokeStyle(lineWidth: 3))
                            
                            AreaMark(
                                x: .value(localizationManager.localizedString("date"), data.0),
                                y: .value(localizationManager.localizedString("weight"), data.1)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            
                            PointMark(
                                x: .value(localizationManager.localizedString("date"), data.0),
                                y: .value(localizationManager.localizedString("weight"), data.1)
                            )
                            .foregroundStyle(.blue)
                            .symbolSize(100)
                        }
                    }
                    .frame(height: 200)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { value in
                            if let date = value.as(Date.self) {
                                AxisValueLabel(format: .dateTime.day().month())
                            }
                        }
                    }
                } else {
                    // Fallback for iOS 15
                    Text("Grafik iOS 16+ gerektirir")
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct ProgressSummarySection: View {
    let viewModel: ProgressViewModel
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: 20) {
                Text(localizationManager.localizedString("summary_title"))
                    .font(.title2)
                    .fontWeight(.bold)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ModernSummaryCard(
                        title: localizationManager.localizedString("current_weight"),
                        value: viewModel.getLatestWeight()?.formatted(.number.precision(.fractionLength(1))) ?? "N/A",
                        unit: "kg",
                        color: .blue,
                        icon: "scalemass.fill"
                    )
                    
                    ModernSummaryCard(
                        title: localizationManager.localizedString("weight_change"),
                        value: viewModel.getWeightChange()?.formatted(.number.precision(.fractionLength(1))) ?? "N/A",
                        unit: "kg",
                        color: viewModel.getWeightChange() ?? 0 >= 0 ? .red : .green,
                        icon: "arrow.up.arrow.down"
                    )
                }
            }
        }
    }
}

struct ModernSummaryCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    let icon: String
    
    @State private var isPressed = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
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

struct BodyCompositionChart: View {
    let measurements: [Measurement]
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "chart.pie.fill")
                        .foregroundColor(.purple)
                        .font(.title2)
                    
                    Text(localizationManager.localizedString("body_composition"))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                
                if let latestMeasurement = measurements.sorted(by: { $0.date > $1.date }).first {
                    let bmi = CalorieCalculator.calculateBMI(weight: latestMeasurement.weight, height: latestMeasurement.height)
                    let bmiCategory = CalorieCalculator.getBMICategory(bmi: bmi)
                    
                    AnimatedProgressRing(
                        progress: getBMICategoryProgress(bmi),
                        title: bmiCategory,
                        subtitle: "VKİ: \(String(format: "%.1f", bmi))",
                        color: getBMICategoryColor(bmi)
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    private func getBMICategoryProgress(_ bmi: Double) -> Double {
        // Normalize BMI to 0-1 range for progress ring
        if bmi < 18.5 { return 0.2 } // Underweight
        else if bmi < 25 { return 0.5 } // Normal
        else if bmi < 30 { return 0.7 } // Overweight
        else if bmi < 35 { return 0.85 } // Obese
        else { return 1.0 } // Severely obese
    }
    
    private func getBMICategoryColor(_ bmi: Double) -> Color {
        switch bmi {
        case ..<18.5: return .blue
        case 18.5..<25: return .green
        case 25..<30: return .orange
        case 30..<35: return .red
        default: return .purple
        }
    }
}

struct ModernMeasurementsList: View {
    let measurements: [Measurement]
    let onDelete: (Measurement) -> Void
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.green)
                        .font(.title2)
                    
                    Text(localizationManager.localizedString("measurement_history"))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("\(measurements.count) \(localizationManager.localizedString("measurement"))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(.green.opacity(0.2))
                        )
                        .foregroundColor(.green)
                }
                
                LazyVStack(spacing: 12) {
                    ForEach(measurements.sorted(by: { $0.date > $1.date })) { measurement in
                        ModernMeasurementRow(measurement: measurement) {
                            onDelete(measurement)
                        }
                    }
                }
            }
        }
    }
}

struct ModernMeasurementRow: View {
    let measurement: Measurement
    let onDelete: () -> Void
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    @State private var isPressed = false
    @State private var showingDetails = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main row content
            HStack(spacing: 20) {
                // Date container with gradient background
                VStack(spacing: 2) {
                    Text(measurement.date.formatted(.dateTime.day()))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(measurement.date.formatted(.dateTime.month(.abbreviated)))
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .frame(width: 60, height: 60)
                .foregroundColor(.white)
                .background(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Primary measurements
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 24) {
                        MeasurementValue(
                            title: localizationManager.localizedString("weight"),
                            value: measurement.weight,
                            unit: "kg",
                            color: .blue
                        )
                        
                        MeasurementValue(
                            title: localizationManager.localizedString("height"),
                            value: measurement.height,
                            unit: "cm",
                            color: .green
                        )
                    }
                }
                
                Spacer()
                
                // Delete button with improved visual feedback
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red.opacity(0.8))
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 36, height: 36)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.red.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            
            // Expandable details section
            if showingDetails {
                VStack(spacing: 16) {
                    Divider()
                        .padding(.horizontal)
                    
                    HStack(spacing: 24) {
                        MeasurementValue(
                            title: localizationManager.localizedString("waist"),
                            value: measurement.waist,
                            unit: "cm",
                            color: .orange
                        )
                        
                        MeasurementValue(
                            title: localizationManager.localizedString("hip"),
                            value: measurement.hip,
                            unit: "cm",
                            color: .purple
                        )
                        
                        MeasurementValue(
                            title: localizationManager.localizedString("arm"),
                            value: measurement.arm,
                            unit: "cm",
                            color: .indigo
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.primary.opacity(0.1), Color.primary.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showingDetails.toggle()
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
            }
        }
    }
}

// Helper view for measurement values
private struct MeasurementValue: View {
    let title: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(String(format: "%.1f", value))
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(color.opacity(0.7))
            }
        }
    }
    }


struct LoadingView: View {
    @State private var isAnimating = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            }
            
            Text(localizationManager.localizedString("loading"))
                .font(.headline)
                .foregroundColor(.primary)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct EmptyStateView: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 8) {
                Text(localizationManager.localizedString("no_measurements"))
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(localizationManager.localizedString("no_measurements_description"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
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
    }
}

#Preview {
    ProgressView()
        .environmentObject(ThemeManager())
        .environmentObject(LocalizationManager.shared)
}

struct TimeRangeButton: View {
    let range: ProgressView.TimeRange
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        Button(action: action) {
            Text(localizationManager.localizedString(range.rawValue))
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(minWidth: 80)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? .blue : Color.clear)
                )
                .foregroundColor(isSelected ? .white : .primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isSelected ? Color.clear : Color.primary.opacity(0.2),
                            lineWidth: 1
                        )
                )
        }
    }
}
