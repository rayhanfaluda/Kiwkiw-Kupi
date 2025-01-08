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
    @Binding var totalPours: Int
    @Binding var waterTemp: Int
    
    let balanceSegments = ["Sweeter", "Standard", "Brighter"]
    let strengthSegments = ["Light", "Medium", "Strong"]
    
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
    }
}

#Preview {
    HomeSimpleView(selectedBalanceSegment: .constant(1),
                   selectedStrengthSegment: .constant(1),
                   totalPours: .constant(5),
                   waterTemp: .constant(88))
}
