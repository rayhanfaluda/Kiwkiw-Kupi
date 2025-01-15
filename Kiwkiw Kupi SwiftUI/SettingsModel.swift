//
//  SettingsModel.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 14/01/25.
//

import SwiftUI

class SettingsManager: ObservableObject {
    @AppStorage("temperatureUnit") var temperatureUnit: TemperatureUnitSegments = .system
    @AppStorage("appearance") var appearance: AppearanceSegments = .system
}

extension SettingsManager {
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
}
