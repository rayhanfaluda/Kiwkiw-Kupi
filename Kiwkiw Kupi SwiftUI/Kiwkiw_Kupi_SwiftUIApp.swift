//
//  Kiwkiw_Kupi_SwiftUIApp.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 20/11/24.
//

import SwiftUI

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
