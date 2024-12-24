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
            .tabItem {
                Label("Brew", systemImage: "cup.and.heat.waves")
            }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "text.page")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    ContentView()
}
