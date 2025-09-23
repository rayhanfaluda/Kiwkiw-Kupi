//
//  ContentView.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 20/11/24.
//

import SwiftUI

struct ContentView: View {
    enum Tab: Hashable { case brew, chat, settings }
    
    @State private var selectedTab: Tab = .brew
    @State private var brewParams: BrewingParams?   // when set → present BrewingView sheet
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            NavigationView {
                HomeView()
                    .navigationTitle("Kiwkiw Kupi")
            }
            .navigationViewStyle(.stack)
            .tabItem { Label("Brew", systemImage: "cup.and.heat.waves") }
            .tag(Tab.brew)
            
            if #available(iOS 26.0, *) {
                NavigationView {
                    ChatView()
                        .navigationTitle("Chat")
                }
                .navigationViewStyle(.stack)
                .tabItem { Label("Chat", systemImage: "wand.and.sparkles") }
                .tag(Tab.chat)
            }
            
            NavigationView {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .navigationViewStyle(.stack)
            .tabItem { Label("Settings", systemImage: "gearshape") }
            .tag(Tab.settings)
        }
        .onOpenURL { url in
            guard let params = DeepLinkParser.parse(url: url) else { return }
            // Route: go to Brew tab, then present the BrewingView sheet
            selectedTab = .brew
            brewParams = params
        }
        // Present BrewingView when we have params
        .sheet(item: $brewParams) { params in
            BrewingSessionSheet(params: params)
        }
    }
}

struct BrewingSessionSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let params: BrewingParams
    
    // Local state mirrors BrewingView's @Binding requirements
    @State private var isPresented: Bool = true
    @State private var brewingMode: ModeSegments
    @State private var coffeeAmount: Double
    @State private var coffeeBalance: BrewBalance
    @State private var coffeeStrength: BrewStrength
    @State private var coffeeRoast: BrewRoast
    @State private var coffeeRatio: Double
    @State private var pourInterval: Int
    
    init(params: BrewingParams) {
        self.params = params
        _brewingMode    = State(initialValue: params.brewingMode)
        _coffeeAmount   = State(initialValue: params.coffeeAmount)
        _coffeeBalance  = State(initialValue: params.coffeeBalance)
        _coffeeStrength = State(initialValue: params.coffeeStrength)
        _coffeeRoast    = State(initialValue: params.coffeeRoast)
        _coffeeRatio    = State(initialValue: params.coffeeRatio)
        _pourInterval   = State(initialValue: params.pourInterval)
    }
    
    var body: some View {
        BrewingView(isPresented: $isPresented,
                    brewingMode: $brewingMode,
                    coffeeAmount: $coffeeAmount,
                    coffeeBalance: $coffeeBalance,
                    coffeeStrength: $coffeeStrength,
                    coffeeRatio: $coffeeRatio,
                    pourInterval: $pourInterval)
        .onChange(of: isPresented, { _, presented in
            if !presented { dismiss() }   // Close the sheet when BrewingView sets isPresented = false
        })
    }
}

enum DeepLinkParser {
    static func parse(url: URL) -> BrewingParams? {
        guard url.scheme == "kiwkiw", url.host == "brew",
              let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else { return nil }
        
        func val(_ k: String) -> String? { items.first { $0.name == k }?.value }
        
        guard
            let modeRaw = val("mode"),
            let mode = ModeSegments(rawValue: modeRaw),
            let coffeeAmount = Double(val("coffeeAmount") ?? ""),
            let balanceRaw = val("balance"),
            let balance = BrewBalance(rawValue: balanceRaw),
            let strengthRaw = val("strength"),
            let strength = BrewStrength(rawValue: strengthRaw),
            let roastRaw = val("roast"),
            let roast = BrewRoast(rawValue: roastRaw),
            let ratio = Double(val("ratio") ?? ""),
            let pourInterval = Int(val("pourInterval") ?? "")
        else { return nil }
        
        return BrewingParams(
            brewingMode: mode,
            coffeeAmount: coffeeAmount,
            coffeeBalance: balance,
            coffeeStrength: strength,
            coffeeRoast: roast,
            coffeeRatio: ratio,
            pourInterval: pourInterval
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(SettingsManager())
        .preferredColorScheme(SettingsManager().appearance.colorScheme)
        .animation(.easeInOut, value: SettingsManager().appearance)
}
