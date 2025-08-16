import SwiftUI

struct ThemeSettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    
    private let accentColors: [Color] = [
        .blue, .purple, .pink, .red, .orange, .yellow, .green, .mint, .teal, .cyan
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        themeManager.isDarkMode ? Color.black.opacity(0.9) : Color.blue.opacity(0.1),
                        themeManager.isDarkMode ? Color.purple.opacity(0.3) : Color.purple.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Theme Mode Section
                        ModernCard {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "paintbrush.fill")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                    
                                    Text(localizationManager.localizedString("theme_mode"))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                }
                                
                                VStack(spacing: 12) {
                                    // System Theme Toggle
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(localizationManager.localizedString("system_theme"))
                                                .font(.headline)
                                            Text(localizationManager.localizedString("system_theme_description"))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Toggle("", isOn: $themeManager.useSystemTheme)
                                            .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor))
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                    )
                                    
                                    if !themeManager.useSystemTheme {
                                        // Manual Theme Toggle
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(localizationManager.localizedString("manual_theme"))
                                                    .font(.headline)
                                                Text(localizationManager.localizedString("manual_theme_description"))
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                themeManager.toggleDarkMode()
                                            }) {
                                                HStack(spacing: 8) {
                                                    Image(systemName: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill")
                                                        .foregroundColor(themeManager.isDarkMode ? .yellow : .purple)
                                                    
                                                    Text(themeManager.isDarkMode ? localizationManager.localizedString("light_mode") : localizationManager.localizedString("dark_mode"))
                                                        .font(.subheadline)
                                                        .fontWeight(.medium)
                                                }
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(.ultraThinMaterial)
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(
                                                            LinearGradient(
                                                                colors: [
                                                                    themeManager.isDarkMode ? Color.yellow.opacity(0.3) : Color.purple.opacity(0.3),
                                                                    themeManager.isDarkMode ? Color.yellow.opacity(0.1) : Color.purple.opacity(0.1)
                                                                ],
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            ),
                                                            lineWidth: 1
                                                        )
                                                )
                                            }
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.systemGray6))
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Accent Color Section
                        ModernCard {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "paintpalette.fill")
                                        .foregroundColor(.purple)
                                        .font(.title2)
                                    
                                    Text(localizationManager.localizedString("accent_color"))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                }
                                
                                Text(localizationManager.localizedString("accent_color_description"))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                                    ForEach(accentColors, id: \.self) { color in
                                        Button(action: {
                                            themeManager.setAccentColor(color)
                                        }) {
                                            Circle()
                                                .fill(color)
                                                .frame(width: 44, height: 44)
                                                .overlay(
                                                    Circle()
                                                        .stroke(
                                                            themeManager.accentColor == color ? Color.white : Color.clear,
                                                            lineWidth: 3
                                                        )
                                                )
                                                .shadow(
                                                    color: color.opacity(0.3),
                                                    radius: themeManager.accentColor == color ? 8 : 4
                                                )
                                                .scaleEffect(themeManager.accentColor == color ? 1.1 : 1.0)
                                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: themeManager.accentColor)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Language Settings Section
                        ModernCard {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "globe")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                    
                                    Text(localizationManager.localizedString("language_settings"))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                }
                                
                                Text(localizationManager.localizedString("language_settings_description"))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                VStack(spacing: 12) {
                                    // System Language Toggle
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(localizationManager.localizedString("system_language"))
                                                .font(.headline)
                                            Text(localizationManager.localizedString("system_language_description"))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Toggle("", isOn: $themeManager.useSystemLanguage)
                                            .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor))
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                    )
                                    
                                    if !themeManager.useSystemLanguage {
                                        // Manual Language Selection
                                        VStack(spacing: 8) {
                                            ForEach(LocalizationManager.Language.allCases, id: \.self) { language in
                                                LanguageSelectionButton(
                                                    language: language,
                                                    isSelected: themeManager.currentLanguage == language
                                                ) {
                                                    themeManager.setLanguage(language)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Preview Section
                        ModernCard {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "eye.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                    
                                    Text(localizationManager.localizedString("preview"))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                }
                                
                                Text(localizationManager.localizedString("preview_description"))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // Preview Card
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Circle()
                                            .fill(themeManager.accentColor)
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Image(systemName: "person.fill")
                                                    .foregroundColor(.white)
                                                    .font(.title3)
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(localizationManager.localizedString("example_user"))
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            Text(localizationManager.localizedString("preview_theme"))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                    }
                                    
                                    Divider()
                                        .background(Color.primary.opacity(0.1))
                                    
                                    HStack(spacing: 16) {
                                        VStack(spacing: 4) {
                                            Text("2200")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(themeManager.accentColor)
                                            
                                            Text(localizationManager.localizedString("calories"))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        VStack(spacing: 4) {
                                            Text("24.5")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(themeManager.accentColor)
                                            
                                            Text(localizationManager.localizedString("bmi"))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                )
                            }
                        }
                        
                        // Reset Button
                        Button(action: {
                            themeManager.setUseSystemTheme(true)
                            themeManager.setAccentColor(.blue)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.title3)
                                
                                Text(localizationManager.localizedString("reset_to_defaults"))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [.red, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .shadow(radius: 8)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle(localizationManager.localizedString("theme_settings"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localizationManager.localizedString("done")) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct LanguageSelectionButton: View {
    let language: LocalizationManager.Language
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(language.flag)
                    .font(.title2)
                
                Text(localizationManager.localizedString(language.rawValue))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.green.opacity(0.1) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.green : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ThemeSettingsView()
        .environmentObject(ThemeManager())
        .environmentObject(LocalizationManager.shared)
}
