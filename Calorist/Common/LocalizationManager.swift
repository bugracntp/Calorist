import SwiftUI
import Foundation

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: Language = .turkish
    
    private let userDefaults = UserDefaults.standard
    private let languageKey = "selectedLanguage"
    
    enum Language: String, CaseIterable {
        case turkish = "tr"
        case english = "en"
        
        var displayName: String {
            switch self {
            case .turkish:
                return "Türkçe"
            case .english:
                return "English"
            }
        }
        
        var flag: String {
            switch self {
            case .turkish:
                return "🇹🇷"
            case .english:
                return "🇺🇸"
            }
        }
        
        var locale: Locale {
            return Locale(identifier: self.rawValue)
        }
    }
    
    init() {
        loadLanguage()
    }
    
    private func loadLanguage() {
        if let savedLanguage = userDefaults.string(forKey: languageKey),
           let language = Language(rawValue: savedLanguage) {
            currentLanguage = language
        } else {
            // Varsayılan olarak sistem dilini kullan
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "tr"
            currentLanguage = Language(rawValue: systemLanguage) ?? .turkish
        }
    }
    
    func setLanguage(_ language: Language) {
        // Ana thread'de güncelle
        DispatchQueue.main.async {
            self.currentLanguage = language
            // ObjectWillChange'i manuel olarak tetikle
            self.objectWillChange.send()
        }
        
        userDefaults.set(language.rawValue, forKey: languageKey)
        
        // Dil değişikliğini uygula
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // NotificationCenter ile bildirim gönder
        NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: language)
    }
    
    func localizedString(_ key: String) -> String {
        let bundle = Bundle.main
        
        if let path = bundle.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
           let languageBundle = Bundle(path: path) {
            return languageBundle.localizedString(forKey: key, value: key, table: nil)
        }
        
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }
}

// MARK: - Localized String Extensions
extension String {
    var localized: String {
        // Global LocalizationManager instance'ını kullan
        let language = LocalizationManager.shared.currentLanguage
        let bundle = Bundle.main
        
        if let path = bundle.path(forResource: language.rawValue, ofType: "lproj"),
           let languageBundle = Bundle(path: path) {
            return languageBundle.localizedString(forKey: self, value: self, table: nil)
        }
        
        return bundle.localizedString(forKey: self, value: self, table: nil)
    }
}
