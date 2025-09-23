//
//  HomeSimpleView.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 30/12/24.
//

import SwiftUI

struct HomeSimpleView: View {
    
    @Binding var selectedBalanceSegment: BrewBalance
    @Binding var selectedStrengthSegment: BrewStrength
    @Binding var selectedRoastSegment: BrewRoast
    @Binding var totalPours: Int
    @Binding var waterTemp: Int
    
    var body: some View {
        // MARK: Balance
        HStack {
            Text("Balance")
                .fontWeight(.medium)
            
            Spacer()
            
            Picker("Select a segment", selection: $selectedBalanceSegment) {
                ForEach(BrewBalance.allCases, id: \.self) { balance in
                    Text(balance.rawValue)
                        .tag(balance)
                }
            }
            .pickerStyle(.automatic)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        
        // MARK: Strength
        HStack {
            Text("Strength")
                .fontWeight(.medium)
            
            Spacer()
            
            Picker("Select a segment", selection: $selectedStrengthSegment) {
                ForEach(BrewStrength.allCases, id: \.self) { strength in
                    Text(strength.rawValue)
                        .tag(strength)
                }
            }
            .pickerStyle(.automatic)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .onChange(of: selectedStrengthSegment, { _, _ in
            totalPours = selectedStrengthSegment == .light ? 4 : selectedStrengthSegment == .medium ? 5 : selectedStrengthSegment == .strong ? 6 : 5
        })
        
        // MARK: Roast
        HStack {
            Text("Roast")
                .fontWeight(.medium)
            
            Spacer()
            
            Picker("Select a segment", selection: $selectedRoastSegment) {
                ForEach(BrewRoast.allCases, id: \.self) { roast in
                    Text(roast.rawValue)
                        .tag(roast)
                }
            }
            .pickerStyle(.automatic)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .onChange(of: selectedRoastSegment, { _, _ in
            waterTemp = selectedRoastSegment == .lightRoast ? 93 : selectedRoastSegment == .mediumRoast ? 88 : selectedRoastSegment == .darkRoast ? 83 : 88
        })
    }
}

#Preview {
    HomeSimpleView(selectedBalanceSegment: .constant(.standard),
                   selectedStrengthSegment: .constant(.medium),
                   selectedRoastSegment: .constant(.mediumRoast),
                   totalPours: .constant(5),
                   waterTemp: .constant(88))
}
