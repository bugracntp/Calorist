import SwiftUI
import Charts

struct AnimatedProgressRing: View {
    let progress: Double
    let title: String
    let subtitle: String
    let color: Color
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State private var animatedProgress: Double = 0
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        LinearGradient(
                            colors: [themeManager.accentColor, themeManager.accentColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.5), value: animatedProgress)
                
                // Center content
                VStack(spacing: 4) {
                    Text("\(Int(progress * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                animatedProgress = progress
            }
        }
    }
}

struct AnimatedBarChart: View {
    let data: [(String, Double)]
    let title: String
    let color: Color
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State private var animatedData: [(String, Double)] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            chartContent
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 8)
        )
        .onAppear {
            animatedData = data.map { ($0.0, 0) }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    animatedData = data
                }
            }
        }
    }
    
    private var chartContent: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(Array(animatedData.enumerated()), id: \.offset) { index, item in
                BarItem(
                    index: index,
                    item: item,
                    color: color
                )
            }
        }
    }
}

struct BarItem: View {
    let index: Int
    let item: (String, Double)
    let color: Color
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            Text(String(format: "%.1f", item.1))
                .font(.caption2)
                .foregroundColor(.secondary)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [themeManager.accentColor, themeManager.accentColor.opacity(0.7)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: 30, height: max(20, CGFloat(item.1) * 2))
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: item.1)
            
            Text(item.0)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct AnimatedLineChart: View {
    let data: [(Date, Double)]
    let title: String
    let color: Color
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State private var animatedData: [(Date, Double)] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            if #available(iOS 16.0, *) {
                chartContent
            } else {
                fallbackContent
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 8)
        )
        .onAppear {
            animatedData = data.map { ($0.0, 0) }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 1.5)) {
                    animatedData = data
                }
            }
        }
    }
    
    @available(iOS 16.0, *)
    private var chartContent: some View {
        Chart {
            ForEach(Array(animatedData.enumerated()), id: \.offset) { index, item in
                LineMark(
                    x: .value("Tarih", item.0),
                    y: .value("Değer", item.1)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [themeManager.accentColor, themeManager.accentColor.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                AreaMark(
                    x: .value("Tarih", item.0),
                    y: .value("Değer", item.1)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [themeManager.accentColor.opacity(0.3), themeManager.accentColor.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                PointMark(
                    x: .value("Tarih", item.0),
                    y: .value("Değer", item.1)
                )
                .foregroundStyle(themeManager.accentColor)
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
    }
    
    private var fallbackContent: some View {
        Text("Grafik iOS 16+ gerektirir")
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
}

struct AnimatedPieChart: View {
    let data: [(String, Double, Color)]
    let title: String
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State private var animatedData: [(String, Double, Color)] = []
    @State private var selectedSlice: Int? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                // Pie Chart
                ZStack {
                    ForEach(Array(animatedData.enumerated()), id: \.offset) { index, item in
                        PieSlice(
                            startAngle: startAngle(for: index),
                            endAngle: endAngle(for: index),
                            color: item.2,
                            isSelected: selectedSlice == index
                        )
                        .scaleEffect(selectedSlice == index ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedSlice)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                selectedSlice = selectedSlice == index ? nil : index
                            }
                        }
                    }
                }
                .frame(width: 120, height: 120)
                
                // Legend
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(animatedData.enumerated()), id: \.offset) { index, item in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(item.2)
                                .frame(width: 12, height: 12)
                            
                            Text(item.0)
                                .font(.caption)
                                .foregroundColor(.primary)
                            
                            Text("\(Int(item.1))%")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 8)
        )
        .onAppear {
            animatedData = data.map { ($0.0, 0, $0.2) }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 1.5)) {
                    animatedData = data
                }
            }
        }
    }
    
    private func startAngle(for index: Int) -> Double {
        let previousValues = animatedData.prefix(index).map { $0.1 }
        let total = animatedData.reduce(0) { $0 + $1.1 }
        let previousSum = previousValues.reduce(0, +)
        return (previousSum / total) * 360
    }
    
    private func endAngle(for index: Int) -> Double {
        let previousValues = animatedData.prefix(index + 1).map { $0.1 }
        let total = animatedData.reduce(0) { $0 + $1.1 }
        let previousSum = previousValues.reduce(0, +)
        return (previousSum / total) * 360
    }
}

struct PieSlice: View {
    let startAngle: Double
    let endAngle: Double
    let color: Color
    let isSelected: Bool
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        Path { path in
            let center = CGPoint(x: 60, y: 60)
            let radius: CGFloat = 50
            
            path.move(to: center)
            path.addArc(
                center: center,
                radius: radius,
                startAngle: Angle(degrees: startAngle),
                endAngle: Angle(degrees: endAngle),
                clockwise: false
            )
            path.closeSubpath()
        }
        .fill(isSelected ? themeManager.accentColor : color)
        .shadow(radius: isSelected ? 8 : 4)
    }
}
