## Calorist

Calorist is a modern iOS app built with SwiftUI that helps you track daily calorie and water intake, visualize progress over time, and understand your body metrics. It features a clean architecture with MVVM, Core Data persistence, and full localization (English and Turkish).

### Features
- **Daily Tracking**: Log daily calorie and water intake; see progress toward goals with visual cards and charts.
- **Calorie Needs**: Calculate daily calorie needs using user profile and activity level.
- **Body Metrics**: Store and view key metrics (BMI, body fat %, weight history).
- **Progress Analytics**: Beautiful charts for weekly/monthly trends and summaries.
- **Localized UI**: English and Turkish localizations via `Localizable.strings`.
- **Theming**: Light/Dark/System theme support with subtle gradients and modern components.
- **Offline-first**: Uses Core Data for local persistence.

### Architecture
Calorist follows a layered, MVVM-first structure influenced by DDD principles:
- **Presentation**: SwiftUI views and view models (`ViewModels/`, `Views/`, `Components/`).
- **Domain**: Business entities, repositories (protocols), and use cases.
- **Data**: DTOs, mappers, and repository implementations using Core Data.

Responsibilities are clearly separated:
- ViewModels expose state and actions for SwiftUI views
- Use cases orchestrate business logic
- Repositories abstract persistence behind protocols

### Project Structure
```text
Calorist/
  Calorist/
    Common/
      CalorieCalculator.swift
      Constants.swift
      LocalizationManager.swift
      ThemeManager.swift
    Data/
      Local/
        CoreDataManager.swift
        MeasurementRepositoryImpl.swift
        UserRepositoryImpl.swift
        DailyTrackingRepositoryImpl.swift
      Mappers/
        MeasurementMapper.swift
        UserMapper.swift
        DailyTrackingMapper.swift
      Models/
        MeasurementDTO.swift
        UserDTO.swift
      DTOs/
        DailyTrackingDTO.swift
      Remote/
    Domain/
      Entities/
        Measurement.swift
        User.swift
        DailyTracking.swift
      Repositories/
        MeasurementRepository.swift
        UserRepository.swift
        DailyTrackingRepository.swift
      UseCases/
        AddMeasurement.swift
        CalculateBodyMetrics.swift
        CalculateDailyCalories.swift
        AddDailyTracking.swift
        GetDailyTracking.swift
    Presentation/
      Components/
        ActivitySettingsCard.swift
        AnimatedCharts.swift
        ModernCalorieSummaryCard.swift
        ModernCard.swift
        UnifiedUserInfoCard.swift
      ViewModels/
        HomeViewModel.swift
        ProgressViewModel.swift
        DailyTrackingViewModel.swift
      Views/
        HomeView.swift
        ProgressView.swift
        DailyTrackingTabView.swift
        DailyTrackingView.swift
        DailyCaloriesView.swift
        BodyMetricsView.swift
        AddMeasurementView.swift
        ThemeSettingsView.swift
        UserSetupView.swift
    Resources/
      Localizations/
        en.lproj/Localizable.strings
        tr.lproj/Localizable.strings
      Fonts/
    Persistence.swift
    Calorist.xcdatamodeld/
  Calorist.xcodeproj/
  CaloristTests/
  CaloristUITests/
```

### Data Model (Core Data)
- `User`: id, name, gender, age, height, weight, activityLevel, goal
- `Measurement`: id, userId, date, weight, body fat %, etc.
- `DailyTracking`: id, userId, date, calorieIntake, waterIntake, timestamps
- `DailyTrackingGoals`: userId, dailyCalorieGoal, dailyWaterGoal, timestamps

Repository implementations convert between domain entities and Core Data models via DTOs and mappers.

### Screens
- **Home**: Unified user info, quick actions, entry points to features.
  <img width="320" alt="image" src="https://github.com/user-attachments/assets/45716070-fec1-4cc3-85c0-1b83d4617b86" />
- **Progress**: Charts, progress summaries, and historical data.
  <img width="320" alt="image" src="https://github.com/user-attachments/assets/c92c5110-bcf6-4b77-af3c-ba0be75f7d1a" />
- **Daily Tracking (Tab)**: Add/view calorie and water intake, goals, and a weekly mini-chart with current-day highlighting.
  <img width="320" alt="image" src="https://github.com/user-attachments/assets/1e65092f-9e42-4858-a7d9-a2653081c58c" />
- **Daily Calories**: Shows calculated daily calories based on profile and activity.
  <img width="320" alt="image" src="https://github.com/user-attachments/assets/cb9cdd7a-78d5-4e0c-9fe8-2309f0cd6be8" />
- **Body Metrics**: Key metrics and latest measurements.
  <img width="320" alt="image" src="https://github.com/user-attachments/assets/6cfa41fb-b67b-4b1d-bb2d-9171cbc7b5c8" />
- **Theme Settings**: Toggle theme preferences.
  <img width="320" alt="image" src="https://github.com/user-attachments/assets/03ec3d51-60c5-4b48-8be0-9dc46be6bf39" />
- **User profile**: Screens for user informatins and measurements.
  <img width="320" alt="image" src="https://github.com/user-attachments/assets/02d58b19-f2f6-447d-a2cc-b7dc67ee2d92" />
  <img width="320" alt="image" src="https://github.com/user-attachments/assets/c01786ad-8b7e-45e4-a8bb-98b42ab75bbf" />



### Requirements
- Xcode 16 or later
- iOS Simulator (example uses iPhone 16)

### Build & Run
Using Xcode:
1. Open `Calorist.xcodeproj` in Xcode
2. Select the `Calorist` scheme
3. Choose a simulator (e.g., iPhone 16)
4. Run (⌘R)

Using command line:
```bash
xcodebuild -project Calorist.xcodeproj -scheme Calorist -destination 'platform=iOS Simulator,name=iPhone 16' build
```

### Tests
- Unit tests live in `CaloristTests/`
- UI tests live in `CaloristUITests/`

Run from Xcode (⌘U) or via command line with your preferred destination.

### Localization
Translations are stored in `Resources/Localizations/`:
- `en.lproj/Localizable.strings`
- `tr.lproj/Localizable.strings`

To add a new key:
1. Add it to English and Turkish `.strings`
2. Use it in code via `localizationManager.localizedString("your_key")`

### Theming
`ThemeManager` controls Light/Dark/System appearance. Views use subtle gradients for a modern look and automatic adjustments per theme.

### Contributing
Contributions are welcome! Please follow the existing architecture (Domain/Data/Presentation), prefer MVVM for new views, and keep localization and theming in mind.

### License
This project currently does not include a license. Add a license file if you plan to distribute or open source the app.

# Calorist

Vücut ölçülerini takip eden ve günlük minimum kalori ihtiyacını hesaplayan iOS uygulaması.

## Özellikler

- **Vücut Ölçü Takibi**: Kilo, boy, yaş, cinsiyet ve aktivite seviyesi kaydetme
- **Kalori Hesaplama**: Harris-Benedict formülü ile BMR ve TDEE hesaplama
- **BMI Hesaplama**: Vücut kitle indeksi hesaplama ve kategorilendirme
- **İlerleme Takibi**: Kilo değişimini grafik ile görselleştirme
- **Veri Kalıcılığı**: Core Data ile ölçümlerin kalıcı olarak saklanması
- **Modern UI**: SwiftUI ile geliştirilmiş kullanıcı dostu arayüz

## Teknik Detaylar

### Mimari
- **Clean Architecture** prensiplerine uygun geliştirilmiştir
- **MVVM** pattern kullanılmıştır
- **Repository Pattern** ile veri erişimi sağlanmıştır

### Katmanlar
- **Domain**: İş mantığı ve varlıklar
- **Data**: Veri erişimi ve Core Data entegrasyonu
- **Presentation**: UI ve ViewModels
- **Common**: Yardımcı sınıflar ve sabitler

### Kullanılan Teknolojiler
- SwiftUI
- Core Data
- Charts Framework (iOS 16+)
- Async/Await

## Kurulum

1. Projeyi Xcode ile açın
2. Gerekli bağımlılıkları yükleyin
3. Simulator veya cihazda çalıştırın

## Kullanım

1. **İlk Ölçüm**: Uygulama açıldığında "Yeni Ölçüm Ekle" butonuna tıklayın
2. **Bilgi Girişi**: Kilo, boy, yaş, cinsiyet ve aktivite seviyenizi girin
3. **Kalori Hesaplama**: Otomatik olarak günlük kalori ihtiyacınız hesaplanır
4. **İlerleme Takibi**: İlerleme sekmesinde kilo değişiminizi görün

## Kalori Hesaplama Formülü

### BMR (Basal Metabolic Rate)
- **Erkek**: 88.362 + (13.397 × kilo) + (4.799 × boy) - (5.677 × yaş)
- **Kadın**: 447.593 + (9.247 × kilo) + (3.098 × boy) - (4.330 × yaş)

### TDEE (Total Daily Energy Expenditure)
- BMR × Aktivite Çarpanı
- **Hareketsiz**: 1.2
- **Az Hareketli**: 1.375
- **Orta Hareketli**: 1.55
- **Çok Hareketli**: 1.725
- **Aşırı Hareketli**: 1.9

### Hedef Kalori
- Kilo vermek için TDEE'nin %80'i

## Gereksinimler

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Commit yapın (`git commit -m 'Add some AmazingFeature'`)
4. Push yapın (`git push origin feature/AmazingFeature`)
5. Pull Request oluşturun
