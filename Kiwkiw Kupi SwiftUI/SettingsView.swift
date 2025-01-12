//
//  SettingsView.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 17/12/24.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var settingsManager: SettingsManager
    
    let temperatureUnitSegments: [TemperatureUnitSegments] = [.system, .celcius, .fahrenheit]
    let appearanceSegments: [AppearanceSegments] = [.system, .light, .dark]
    
    var body: some View {
        List {
            Section(header: Text("Kiwkiw Kupi Pro").textCase(nil)) {
                Text("Subscribe to Kiwkiw Kupi Pro")
                Text("Restore Purchase")
            }
            Section(header: Text("General").textCase(nil)) {
                Picker("Temperature Unit", selection: $settingsManager.temperatureUnit) {
                    let systemUnit = Locale.current.usesMetricSystem ? "C" : "F"
                    ForEach(temperatureUnitSegments, id: \.self) { temperatureUnit in
                        Text(temperatureUnit == .system ? "\(temperatureUnit.rawValue) (°\(systemUnit))" : "°\(temperatureUnit.rawValue)")
                    }
                }
                .pickerStyle(.automatic)
                
                Picker("Appearance", selection: $settingsManager.appearance) {
                    let systemAppearance = colorScheme == .light ? "Light" : "Dark"
                    ForEach(appearanceSegments, id: \.self) { appearance in
                        Text(appearance == .system ? "\(appearance.rawValue) (\(systemAppearance))" : appearance.rawValue)
                    }
                }
                .pickerStyle(.automatic)
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

#Preview {
    SettingsView()
}
