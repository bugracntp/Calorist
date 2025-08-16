//
//  ContentView.swift
//  Calorist
//
//  Created by Bugra Cantepe on 15.08.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text(localizationManager.localizedString("home"))
                }
            
            ProgressView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text(localizationManager.localizedString("progress"))
                }
        }
        .preferredColorScheme(themeManager.useSystemTheme ? nil : (themeManager.isDarkMode ? .dark : .light))
        .accentColor(themeManager.accentColor)
        .environmentObject(themeManager)
        .environmentObject(localizationManager)
    }
}

#Preview {
    ContentView()
}
