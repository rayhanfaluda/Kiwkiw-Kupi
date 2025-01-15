//
//  ContentView.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 20/11/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                HomeView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Brew", systemImage: "cup.and.heat.waves")
            }
            
            NavigationView {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SettingsManager())
        .preferredColorScheme(SettingsManager().appearance.colorScheme)
        .animation(.easeInOut, value: SettingsManager().appearance)
}
