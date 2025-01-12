//
//  SettingsView.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 17/12/24.
//

import SwiftUI

struct SettingsView: View {
    
    // Appearance
    @EnvironmentObject var themeManager: ThemeManager
    let appearanceSegments: [AppearanceSegments] = [.system, .light, .dark]
    
    var body: some View {
        List {
            Section(header: Text("Kiwkiw Kupi Pro").textCase(nil)) {
                Text("Subscribe to Kiwkiw Kupi Pro")
                Text("Restore Purchase")
            }
            Section(header: Text("General").textCase(nil)) {
                Text("Temperature Unit")
                Picker("Appearance", selection: $themeManager.appearance) {
                    ForEach(appearanceSegments, id: \.self) { appearance in
                        appearance == .system ? Text("\(appearance.rawValue) (Default)") : Text(appearance.rawValue)
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

enum AppearanceSegments: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
}
