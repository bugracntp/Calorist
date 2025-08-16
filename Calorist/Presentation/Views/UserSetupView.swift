import SwiftUI

// Import entities and components from Domain and Presentation layers
// Note: In a real project, you might need to adjust the import paths
struct UserSetupView: View {
    let onUserCreated: (User, Measurement) -> Void
    
    @State private var name = ""
    @State private var age = 25
    @State private var gender = Gender.male
    
    @State private var activityLevel = ActivityLevel.moderatelyActive
    @State private var goal = Goal.maintainWeight
    @State private var currentStep = 0
    
    // Vücut ölçüleri
    @State private var height = 170.0
    @State private var weight = 70.0
    @State private var neck = 35.0
    @State private var waist = 80.0
    @State private var hip = 95.0
    @State private var arm = 30.0
    
    private let totalSteps = 3
    
    var body: some View {
        VStack(spacing: 20) {
            // Hoş geldiniz mesajı sadece ilk sayfada
            if currentStep == 0 {
                VStack(spacing: 16) {
                    Text("Hoş Geldiniz!")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    Text("Calorist uygulamasını kullanmaya başlamak için lütfen bilgilerinizi girin.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 20)
                }
            }
            
            // Progress indicator
            VStack(spacing: 8) {
                // Custom progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geometry.size.width, height: 6)
                            .opacity(0.2)
                            .foregroundColor(.gray)
                        
                        Rectangle()
                            .frame(width: geometry.size.width * CGFloat(currentStep + 1) / CGFloat(totalSteps), height: 6)
                            .foregroundColor(.blue)
                            .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal)
                
                Text("\(currentStep + 1) / \(totalSteps)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Step title
            Text(getStepTitle())
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top)
            
            // Step content
            Group {
                switch currentStep {
                case 0:
                    basicInfoStep
                case 1:
                    bodyMeasurementsStep
                case 2:
                    goalsStep
                default:
                    EmptyView()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: currentStep)
            
            Spacer()
            
            // Navigation buttons
            HStack {
                if currentStep > 0 {
                    Button("Geri") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep -= 1
                        }
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
                
                Button(currentStep == totalSteps - 1 ? "Bitir" : "İleri") {
                    if currentStep == totalSteps - 1 {
                        createUser()
                    } else {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep += 1
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canProceed())
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Kullanıcı Kurulumu")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var basicInfoStep: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Ad Soyad")
                    .font(.headline)
                TextField("Adınızı girin", text: $name)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Yaş")
                    .font(.headline)
                Stepper("\(age) yaş", value: $age, in: Constants.Health.minAge...Constants.Health.maxAge)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Cinsiyet")
                    .font(.headline)
                Picker("Cinsiyet", selection: $gender) {
                    ForEach(Gender.allCases, id: \.self) { gender in
                        Text(gender.displayName).tag(gender)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
    
    private var bodyMeasurementsStep: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Boy")
                    .font(.headline)
                HStack {
                    TextField("Boy", value: $height, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    Text("cm")
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Kilo")
                    .font(.headline)
                HStack {
                    TextField("Kilo", value: $weight, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    Text("kg")
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Boyun Çevresi")
                    .font(.headline)
                HStack {
                    TextField("Boyun", value: $neck, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    Text("cm")
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Bel Çevresi")
                    .font(.headline)
                HStack {
                    TextField("Bel", value: $waist, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    Text("cm")
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Kalça Çevresi")
                    .font(.headline)
                HStack {
                    TextField("Kalça", value: $hip, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    Text("cm")
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Kol Çevresi")
                    .font(.headline)
                HStack {
                    TextField("Kol", value: $arm, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    Text("cm")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var goalsStep: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Aktivite Seviyesi")
                    .font(.headline)
                Picker("Aktivite Seviyesi", selection: $activityLevel) {
                    ForEach(ActivityLevel.allCases, id: \.self) { level in
                        Text(level.displayName).tag(level)
                    }
                }
                .pickerStyle(.wheel)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Hedef")
                    .font(.headline)
                Picker("Hedef", selection: $goal) {
                    ForEach(Goal.allCases, id: \.self) { goal in
                        Text(goal.displayName).tag(goal)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
    
    private func getStepTitle() -> String {
        switch currentStep {
        case 0: return "Temel Bilgiler"
        case 1: return "Vücut Ölçüleri"
        case 2: return "Hedefler ve Aktivite"
        default: return ""
        }
    }
    
    private func canProceed() -> Bool {
        switch currentStep {
        case 0:
            return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 1:
            return height > 0 && weight > 0 && neck > 0 && waist > 0 && hip > 0 && arm > 0
        case 2:
            return true // All selections have default values
        default:
            return false
        }
    }
    
    private func createUser() {
        let user = User(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            age: age,
            gender: gender,
            activityLevel: activityLevel,
            goal: goal
        )
        
        print("DEBUG: User oluşturuluyor - name: \(user.name), age: \(user.age), gender: \(gender.rawValue), activity: \(activityLevel.rawValue), goal: \(goal.rawValue)")
        
        // İlk ölçümü oluştur
        let initialMeasurement = Measurement(
            userId: user.id,
            height: height,
            weight: weight,
            neck: neck,
            waist: waist,
            hip: hip,
            arm: arm
        )
        
        print("DEBUG: Measurement oluşturuluyor - height: \(height), weight: \(weight)")
        
        onUserCreated(user, initialMeasurement)
    }
}

#Preview {
    NavigationView {
        UserSetupView { _, _ in }
    }
}
