//
//  ContentView.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 20/11/24.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    @AppStorage("appearance") private var appearance: AppearanceSegments = .system
    
    var body: some View {
        TabView {
            NavigationView {
                HomeView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Brew", systemImage: "cup.and.heat.waves")
            }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "text.page")
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
        .preferredColorScheme(
            if appearance == .dark {
                .dark
            } else if appearance == .light {
                .light
            } else {
                .none
            }
        )
    }
}

#Preview {
    ContentView()
}
