//
//  HomeView.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 17/12/24.
//

import SwiftUI

struct HomeView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var coffeeAmount: Double = 200
    @State var selectedCoffeeRatio: Double = 15
    @State var selectedBalanceSegment = 1
    @State var selectedStrengthSegment = 1
    @State var selectedRoastSegment = 1
    @State var selectedPourInterval = 45
    @State var totalPours = 5
    @State var waterTemp = 88
    @State var brewingMode: ModeSegments = .simple
    @State var isFullScreenPresented = false
    
    let modeSegments: [ModeSegments] = [.simple, .advanced, .iced]
    
    let lightBrown = "#ede0d4"
    let darkBrown = "#b08968"
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Kiwkiw Kupi")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(.bottom)
                
                Picker("Brewing Mode", selection: $brewingMode) {
                    ForEach(modeSegments, id: \.self) { mode in
                        Text(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.bottom)
                .onChange(of: brewingMode) { _ in
                    if brewingMode == .iced {
                        selectedBalanceSegment = 0
                        totalPours = 3
                    } else {
                        selectedBalanceSegment = 1
                        totalPours = 5
                    }
                }
                
                // MARK: Coffee Size
                HStack {
                    Text("Size")
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Picker("Coffee Amount", selection: $coffeeAmount) {
                        let maxCoffeeAmount = brewingMode == .simple ? 500.0 : 610.0
                        let increment = brewingMode == .simple ? 100.0 : 10.0
                        ForEach(Array(stride(from: 200.0, to: maxCoffeeAmount, by: increment)), id: \.self) { size in
                            switch size {
                            case 200.0: Text("\(Int(size)) ml (Small)").tag(size)
                            case 300.0: Text("\(Int(size)) ml (Medium)").tag(size)
                            case 400.0: Text("\(Int(size)) ml (Large)").tag(size)
                            case 500.0: Text("\(Int(size)) ml (X Large)").tag(size)
                            case 600.0: Text("\(Int(size)) ml (XX Large)").tag(size)
                            default: Text("\(Int(size)) ml").tag(size)
                            }
                        }
                    }
                    .pickerStyle(.automatic)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                switch brewingMode {
                case .simple:
                    HomeSimpleView(selectedBalanceSegment: $selectedBalanceSegment,
                                   selectedStrengthSegment: $selectedStrengthSegment,
                                   selectedRoastSegment: $selectedRoastSegment,
                                   totalPours: $totalPours,
                                   waterTemp: $waterTemp)
                case .advanced:
                    HomeSimpleView(selectedBalanceSegment: $selectedBalanceSegment,
                                   selectedStrengthSegment: $selectedStrengthSegment,
                                   selectedRoastSegment: $selectedRoastSegment,
                                   totalPours: $totalPours,
                                   waterTemp: $waterTemp)
                    
                    HomeAdvancedView(selectedCoffeeRatio: $selectedCoffeeRatio,
                                     selectedPourInterval: $selectedPourInterval)
                case .iced:
                    EmptyView()
                }
                
                Spacer().frame(height: 40)
                
                // MARK: Summary
                HStack(alignment: .center) {
                    VStack {
                        /*Text("Total")
                         .fontWeight(.medium)*/
                        
                        Text("\(totalPours)")
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Text("pours")
                            .fontWeight(.medium)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color(hex: colorScheme == .light ? lightBrown : darkBrown))
                    .cornerRadius(8)
                    
                    VStack {
                        /*Text("Estimated")
                         .fontWeight(.medium)*/
                        
                        let totalTime = totalPours * selectedPourInterval
                        Text(formatTime(TimeInterval(totalTime)))
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Text("total time")
                            .fontWeight(.medium)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color(hex: colorScheme == .light ? lightBrown : darkBrown))
                    .cornerRadius(8)
                }
                
                HStack {
                    VStack {
                        /*Text("Prepare")
                         .fontWeight(.medium)*/
                        
                        let groundCoffeeAmount = Int(coffeeAmount/selectedCoffeeRatio.rounded())
                        Text("\(groundCoffeeAmount)g")
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Text("of ground coffee")
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color(hex: colorScheme == .light ? lightBrown : darkBrown))
                    .cornerRadius(8)
                    
                    VStack {
                        /*Text("Prepare")
                         .fontWeight(.medium)*/
                        
                        Text(brewingMode != .iced ? "\(waterTemp)°C" : "91-96°C")
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Text("water temp")
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color(hex: colorScheme == .light ? lightBrown : darkBrown))
                    .cornerRadius(8)
                }
                
                if brewingMode == .iced {
                    VStack {
                        Text("Prepare")
                         .fontWeight(.medium)
                        
                        let iceAmount = Int((coffeeAmount * 40) / 100)
                        Text("\(iceAmount)g")
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Text("of ice")
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color(hex: colorScheme == .light ? lightBrown : darkBrown))
                    .cornerRadius(8)
                }
                
                Spacer().frame(height: 40)
                
                Button {
                    isFullScreenPresented = true
                } label: {
                    Text("Start Brewing")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBlue))
                        .cornerRadius(8)
                }
                .fullScreenCover(isPresented: $isFullScreenPresented) {
                    BrewingView(isPresented: $isFullScreenPresented,
                                brewingMode: $brewingMode,
                                coffeeAmount: $coffeeAmount,
                                coffeeBalance: $selectedBalanceSegment,
                                coffeeStrength: $selectedStrengthSegment,
                                coffeeRatio: $selectedCoffeeRatio,
                                pourInterval: $selectedPourInterval)
                }
            }
            .padding()
        }
    }
    
    // Format the elapsed time into mm:ss
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    HomeView()
}

enum ModeSegments: String, CaseIterable {
    case simple = "Simple"
    case advanced = "Advanced"
    case iced = "Iced"
}
