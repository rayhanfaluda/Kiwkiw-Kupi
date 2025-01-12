//
//  Kiwkiw_Kupi_SwiftUIApp.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 20/11/24.
//

import SwiftUI

class SettingsManager: ObservableObject {
    @Published var temperatureUnit: TemperatureUnitSegments {
        didSet {
            // Save the raw value to UserDefaults
            UserDefaults.standard.set(temperatureUnit.rawValue, forKey: "temperatureUnit") // Save state
        }
    }
    
    @Published var appearance: AppearanceSegments {
        didSet {
            // Save the raw value to UserDefaults
            UserDefaults.standard.set(appearance.rawValue, forKey: "appearance") // Save state
        }
    }
    
    init() {
        // Load the raw value from UserDefaults and convert it back to the enum
        if let rawTemperatureUnitValue = UserDefaults.standard.string(forKey: "temperatureUnit"),
           let savedTemperatureUnit = TemperatureUnitSegments(rawValue: rawTemperatureUnitValue) {
            self.temperatureUnit = savedTemperatureUnit
        } else {
            self.temperatureUnit = .system // Default value
        }
        
        if let rawAppearanceValue = UserDefaults.standard.string(forKey: "appearance"),
           let savedAppearance = AppearanceSegments(rawValue: rawAppearanceValue) {
            self.appearance = savedAppearance
        } else {
            self.appearance = .system // Default value
        }
    }
}

@main
struct Kiwkiw_Kupi_SwiftUIApp: App {
    
    @StateObject private var settingsManager = SettingsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settingsManager)
                .preferredColorScheme(settingsManager.appearance == .system ? .none : settingsManager.appearance == .light ? .light : settingsManager.appearance == .dark ? .dark : .none)
                .animation(.easeInOut, value: settingsManager.appearance)
        }
    }
}

enum TemperatureUnitSegments: String, CaseIterable {
    case system = "System"
    case celcius = "C"
    case fahrenheit = "F"
}

enum AppearanceSegments: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
}
