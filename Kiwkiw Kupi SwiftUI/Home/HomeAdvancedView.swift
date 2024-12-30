//
//  HomeAdvancedView.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 30/12/24.
//

import SwiftUI

struct HomeAdvancedView: View {
    
    @Binding var selectedCoffeeRatio: Double
    @Binding var selectedPourInterval: Int
    
    var body: some View {
        // MARK: Coffee Ratio
        HStack {
            Text("Ratio")
                .fontWeight(.medium)
            
            Spacer()
            
            Picker("Select a segment", selection: $selectedCoffeeRatio) {
                ForEach(Array(stride(from: 14.0, to: 17.0, by: 1.0)), id: \.self) { number in
                    if number == 15.0 {
                        Text("1:\(Int(number)) (Default)")
                    } else {
                        Text("1:\(Int(number))")
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
}

#Preview {
    HomeAdvancedView(selectedCoffeeRatio: .constant(15),
                     selectedPourInterval: .constant(45))
}
