//
//  SettingsView.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 17/12/24.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    @State var selectedAppearance: AppearanceSegments = .system
    
    let appearanceSegments: [AppearanceSegments] = [.system, .light, .dark]
    
    var body: some View {
        List {
            Section(header: Text("Kiwkiw Kupi Pro").textCase(nil)) {
                Text("Subscribe to Kiwkiw Kupi Pro")
                Text("Restore Purchase")
            }
            Section(header: Text("General").textCase(nil)) {
                Text("Temperature Unit")
                HStack {
                    Text("Size")
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Picker("Appearance", selection: $selectedAppearance) {
                        ForEach(appearanceSegments, id: \.self) { appearance in
                            Text(appearance.rawValue)
                        }
                    }
                    .pickerStyle(.automatic)
                }
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
