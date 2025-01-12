//
//  Kiwkiw_Kupi_SwiftUIApp.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 20/11/24.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @Published var appearance: AppearanceSegments {
        didSet {
            // Save the raw value to UserDefaults
            UserDefaults.standard.set(appearance.rawValue, forKey: "appearance") // Save state
        }
    }
    
    init() {
        // Load the raw value from UserDefaults and convert it back to the enum
        if let rawValue = UserDefaults.standard.string(forKey: "appearance"),
           let savedAppearance = AppearanceSegments(rawValue: rawValue) {
            self.appearance = savedAppearance
        } else {
            self.appearance = .system // Default value
        }
    }
}

@main
struct Kiwkiw_Kupi_SwiftUIApp: App {
    
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.appearance == .system ? .none : themeManager.appearance == .light ? .light : themeManager.appearance == .dark ? .dark : .none)
                .animation(.easeInOut, value: themeManager.appearance)
        }
    }
}
