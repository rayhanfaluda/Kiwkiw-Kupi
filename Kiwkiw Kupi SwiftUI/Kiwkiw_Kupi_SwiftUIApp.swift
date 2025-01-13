//
//  Kiwkiw_Kupi_SwiftUIApp.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 20/11/24.
//

import SwiftUI

class SettingsManager: ObservableObject {
    @AppStorage("temperatureUnit") var temperatureUnit: TemperatureUnitSegments = .system
    @AppStorage("appearance") var appearance: AppearanceSegments = .system
}

@main
struct Kiwkiw_Kupi_SwiftUIApp: App {
    
    @StateObject private var settingsManager = SettingsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settingsManager)
                .preferredColorScheme(settingsManager.appearance.colorScheme)
                .animation(.easeInOut, value: settingsManager.appearance)
        }
    }
}

enum TemperatureUnitSegments: String, CaseIterable {
    case system = "System"
    case celcius = "C"
    case fahrenheit = "F"
}

enum AppearanceSegments: String, CaseIterable, Identifiable {
    case system
    case light
    case dark
    
    var id: String { self.rawValue }
    
    // Map Appearance cases to SwiftUI's ColorScheme
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil // Follow system
        case .light: return .light
        case .dark: return .dark
        }
    }
}
