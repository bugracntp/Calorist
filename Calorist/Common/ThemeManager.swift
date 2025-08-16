import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = false
    @Published var accentColor: Color = .blue
    @Published var useSystemTheme: Bool = true
    @Published var currentLanguage: LocalizationManager.Language = .turkish
    @Published var useSystemLanguage: Bool = true
    
    private let userDefaults = UserDefaults.standard
    private let isDarkModeKey = "isDarkMode"
    private let accentColorKey = "accentColor"
    private let useSystemThemeKey = "useSystemTheme"
    private let currentLanguageKey = "currentLanguage"
    private let useSystemLanguageKey = "useSystemLanguage"
    
    init() {
        loadSettings()
        setupSystemThemeObserver()
    }
    
    private func loadSettings() {
        isDarkMode = userDefaults.bool(forKey: isDarkModeKey)
        useSystemTheme = userDefaults.bool(forKey: useSystemThemeKey)
        useSystemLanguage = userDefaults.bool(forKey: useSystemLanguageKey)
        
        if let colorData = userDefaults.data(forKey: accentColorKey),
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            accentColor = Color(color)
        }
        
        if let languageString = userDefaults.string(forKey: currentLanguageKey),
           let language = LocalizationManager.Language(rawValue: languageString) {
            currentLanguage = language
        }
    }
    
    private func setupSystemThemeObserver() {
        if useSystemTheme {
            isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        }
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
        userDefaults.set(isDarkMode, forKey: isDarkModeKey)
    }
    
    func setAccentColor(_ color: Color) {
        accentColor = color
        if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(color), requiringSecureCoding: false) {
            userDefaults.set(colorData, forKey: accentColorKey)
        }
    }
    
    func setUseSystemTheme(_ use: Bool) {
        useSystemTheme = use
        userDefaults.set(use, forKey: useSystemThemeKey)
        if use {
            setupSystemThemeObserver()
        }
    }
    
    func setLanguage(_ language: LocalizationManager.Language) {
        currentLanguage = language
        userDefaults.set(language.rawValue, forKey: currentLanguageKey)
        
        // LocalizationManager'ı da güncelle
        LocalizationManager.shared.setLanguage(language)
        
        // Dil değişikliğini uygula
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    func setUseSystemLanguage(_ use: Bool) {
        useSystemLanguage = use
        userDefaults.set(use, forKey: useSystemLanguageKey)
        
        if use {
            // Sistem dilini kullan
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "tr"
            if let language = LocalizationManager.Language(rawValue: systemLanguage) {
                setLanguage(language)
            }
        }
    }
}

// MARK: - Color Extensions
extension Color {
    static let customBackground = Color("CustomBackground")
    static let customSecondaryBackground = Color("CustomSecondaryBackground")
    static let customText = Color("CustomText")
    static let customSecondaryText = Color("CustomSecondaryText")
    
    static let gradientStart = Color("GradientStart")
    static let gradientEnd = Color("GradientEnd")
    
    static let successGreen = Color("SuccessGreen")
    static let warningOrange = Color("WarningOrange")
    static let errorRed = Color("ErrorRed")
    static let infoBlue = Color("InfoBlue")
}

// MARK: - Custom Colors
struct CustomColors {
    static let lightBackground = Color(red: 0.98, green: 0.98, blue: 0.98)
    static let darkBackground = Color(red: 0.1, green: 0.1, blue: 0.12)
    
    static let lightSecondaryBackground = Color(red: 1.0, green: 1.0, blue: 1.0)
    static let darkSecondaryBackground = Color(red: 0.15, green: 0.15, blue: 0.17)
    
    static let lightText = Color(red: 0.1, green: 0.1, blue: 0.1)
    static let darkText = Color(red: 0.95, green: 0.95, blue: 0.97)
    
    static let lightSecondaryText = Color(red: 0.4, green: 0.4, blue: 0.4)
    static let darkSecondaryText = Color(red: 0.7, green: 0.7, blue: 0.7)
}
