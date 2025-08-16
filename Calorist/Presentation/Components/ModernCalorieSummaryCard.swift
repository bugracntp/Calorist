import SwiftUI

struct ModernCalorieSummaryCard: View {
    let dailyCalories: Double
    let bmi: Double
    let bodyFatPercentage: Double
    
    @State private var animateValues = false
    @State private var showProgressRing = false
    
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
                        
                        Image(systemName: "flame.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Günlük Kalori İhtiyacı")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("BMR + Aktivite Faktörü")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Main calorie display
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(Int(dailyCalories))")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .opacity(animateValues ? 1 : 0)
                            .offset(y: animateValues ? 0 : 20)
                        
                        Text("kalori/gün")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .opacity(animateValues ? 1 : 0)
                            .offset(y: animateValues ? 0 : 20)
                    }
                    
                    Spacer()
                    
                    // Progress ring
                    ZStack {
                        Circle()
                            .stroke(Color.orange.opacity(0.2), lineWidth: 8)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: showProgressRing ? 0.8 : 0)
                            .stroke(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1.5), value: showProgressRing)
                        
                        VStack(spacing: 2) {
                            Text("80%")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            
                            Text("Hedef")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Divider()
                    .background(Color.primary.opacity(0.1))
                
                // BMI and Body Fat info
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                            
                            Text("VKİ")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(String(format: "%.1f", bmi))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(getBMIColor(bmi: bmi))
                        
                        Text(CalorieCalculator.getBMICategory(bmi: bmi))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(getBMIColor(bmi: bmi).opacity(0.2))
                            )
                            .foregroundColor(getBMIColor(bmi: bmi))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            
                            Text("Yağ Oranı")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(String(format: "%.1f%%", bodyFatPercentage))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(getBodyFatColor(bodyFatPercentage))
                        
                        Text(getBodyFatCategory(bodyFatPercentage))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(getBodyFatColor(bodyFatPercentage).opacity(0.2))
                            )
                            .foregroundColor(getBodyFatColor(bodyFatPercentage))
                    }
                }
                
                // Additional info
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    
                    Text("Kalori ihtiyacınız yaş, cinsiyet, boy, kilo ve aktivite seviyenize göre hesaplanmıştır.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                )
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                animateValues = true
            }
            
            withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
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
    
    private func getBodyFatCategory(_ percentage: Double) -> String {
        if percentage < 10 { return "Çok Düşük" }
        else if percentage < 20 { return "Düşük" }
        else if percentage < 30 { return "Normal" }
        else if percentage < 40 { return "Yüksek" }
        else { return "Çok Yüksek" }
    }
}

#Preview {
    ModernCalorieSummaryCard(
        dailyCalories: 2200,
        bmi: 24.5,
        bodyFatPercentage: 18.5
    )
    .padding()
}
