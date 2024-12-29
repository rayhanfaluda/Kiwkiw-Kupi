//
//  HomeView.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 17/12/24.
//

import SwiftUI

struct HomeView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var coffeeAmount = 200
    @State var selectedCoffeeRatio = 15
    @State var selectedBalanceSegment = 1
    @State var selectedStrengthSegment = 1
    @State var selectedRoastSegment = 1
    @State var selectedPourInterval = 45
    @State var totalPours = 5
    @State var waterTemp = 88
    @State var brewingMode = "Simple"
    @State var isFullScreenPresented = false
    
    let modeSegments = ["Simple", "Advanced"]
    let balanceSegments = ["Sweeter", "Standard", "Brighter"]
    let strengthSegments = ["Light", "Medium", "Strong"]
    let roastSegments = ["Light Roast", "Medium Roast", "Dark Roast"]
    
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
                        Text(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.bottom)
                
                // MARK: Coffee Size
                HStack {
                    Text("Size")
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Picker("Coffee Amount", selection: $coffeeAmount) {
                        let maxCoffeeAmount = brewingMode == "Simple" ? 500 : 610
                        let increment = brewingMode == "Simple" ? 100 : 10
                        ForEach(Array(stride(from: 200, to: maxCoffeeAmount, by: increment)), id: \.self) { size in
                            switch size {
                            case 200: Text("\(size) ml (Small)").tag(size)
                            case 300: Text("\(size) ml (Medium)").tag(size)
                            case 400: Text("\(size) ml (Large)").tag(size)
                            case 500: Text("\(size) ml (X Large)").tag(size)
                            case 600: Text("\(size) ml (XX Large)").tag(size)
                            default: Text("\(size) ml").tag(size)
                            }
                        }
                    }
                    .pickerStyle(.automatic)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                if brewingMode != "Simple" {
                    // MARK: Coffee Ratio
                    HStack {
                        Text("Ratio")
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Picker("Select a segment", selection: $selectedCoffeeRatio) {
                            ForEach(Array(stride(from: 14, to: 17, by: 1)), id: \.self) { number in
                                if number == 15 {
                                    Text("1:\(number) (Default)")
                                } else {
                                    Text("1:\(number)")
                                }
                            }
                        }
                        .pickerStyle(.automatic)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    // MARK: Pour Interval
                    HStack {
                        Text("Interval")
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Picker("Select a segment", selection: $selectedPourInterval) {
                            ForEach(Array(stride(from: 30, to: 50, by: 5)), id: \.self) { number in
                                if number == 45 {
                                    Text("\(number)s (Default)")
                                } else {
                                    Text("\(number)s")
                                }
                            }
                        }
                        .pickerStyle(.automatic)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                // MARK: Balance
                HStack {
                    Text("Balance")
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Picker("Select a segment", selection: $selectedBalanceSegment) {
                        ForEach(0..<balanceSegments.count, id: \.self) { index in
                            Text(balanceSegments[index])
                                .tag(index)
                        }
                    }
                    .pickerStyle(.automatic)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // MARK: Strength
                HStack {
                    Text("Strength")
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Picker("Select a segment", selection: $selectedStrengthSegment) {
                        ForEach(0..<strengthSegments.count, id: \.self) { index in
                            Text(strengthSegments[index])
                                .tag(index)
                        }
                    }
                    .pickerStyle(.automatic)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .onChange(of: selectedStrengthSegment) { _ in
                    totalPours = selectedStrengthSegment == 0 ? 4 : selectedStrengthSegment == 1 ? 5 : selectedStrengthSegment == 2 ? 6 : 5
                }
                
                // MARK: Roast
                HStack {
                    Text("Roast")
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Picker("Select a segment", selection: $selectedRoastSegment) {
                        ForEach(0..<roastSegments.count, id: \.self) { index in
                            Text(roastSegments[index])
                                .tag(index)
                        }
                    }
                    .pickerStyle(.automatic)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.bottom, 32)
                .onChange(of: selectedRoastSegment) { _ in
                    waterTemp = selectedRoastSegment == 0 ? 93 : selectedRoastSegment == 1 ? 88 : selectedRoastSegment == 2 ? 83 : 88
                }
                
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
                        
                        Text("\(coffeeAmount/selectedCoffeeRatio)g")
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
                        
                        Text("\(waterTemp)°C")
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
                .padding(.bottom, 32)
                
                Button {
                    isFullScreenPresented = true
                } label: {
                    Text("Start Brewing")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemBlue))
                .cornerRadius(8)
                .fullScreenCover(isPresented: $isFullScreenPresented) {
                    BrewingView(isPresented: $isFullScreenPresented,
                                coffeeAmount: $coffeeAmount,
                                coffeeBalance: $selectedBalanceSegment,
                                coffeeStrength: $selectedStrengthSegment,
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
