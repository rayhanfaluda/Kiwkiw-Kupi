//
//  HomeSimpleView.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 30/12/24.
//

import SwiftUI

struct HomeSimpleView: View {
    
    @Binding var selectedBalanceSegment: Int
    @Binding var selectedStrengthSegment: Int
    @Binding var selectedRoastSegment: Int
    @Binding var totalPours: Int
    @Binding var waterTemp: Int
    
    let balanceSegments = ["Sweeter", "Standard", "Brighter"]
    let strengthSegments = ["Light", "Medium", "Strong"]
    let roastSegments = ["Light Roast", "Medium Roast", "Dark Roast"]
    
    var body: some View {
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
        .onChange(of: selectedRoastSegment) { _ in
            waterTemp = selectedRoastSegment == 0 ? 93 : selectedRoastSegment == 1 ? 88 : selectedRoastSegment == 2 ? 83 : 88
        }
    }
    
}

#Preview {
    HomeSimpleView(selectedBalanceSegment: .constant(1),
                   selectedStrengthSegment: .constant(1),
                   selectedRoastSegment: .constant(1),
                   totalPours: .constant(5),
                   waterTemp: .constant(88))
}
