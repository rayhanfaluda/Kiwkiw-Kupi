//
//  BrewPlan.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 18/09/25.
//

import FoundationModels

@available(iOS 26.0, *)
@Generable
public enum BrewStyle: String, Codable, CaseIterable {
    case hot, iced
}

@available(iOS 26.0, *)
@Generable
public struct BrewPlan: Equatable, Codable {
    // Decide hot vs iced from chat context (iced → Japanese iced / flash brew).
    @Guide(description: "hot or iced; choose iced if user asks for iced/Japanese iced/flash brew.")
    public var style: BrewStyle
    
    // Match BrewingView scales exactly (0,1,2):
    @Guide(description: "0 sweeter, 1 balanced, 2 brighter", .range(0...2))
    public var balanceLevel: Int
    
    @Guide(description: "0 light, 1 medium, 2 strong", .range(0...2))
    public var strengthLevel: Int
    
    // Quantities
    @Guide(description: "Coffee dose in grams.", .range(10.0...40.0))
    public var coffeeGrams: Double
    
    @Guide(description: "Water ratio, e.g. 15.0 means 1:15.", .range(13.0...18.0))
    public var ratio: Double
    
    @Guide(description: "Seconds between pours.", .range(15...45))
    public var pourIntervalSec: Int
    
    // One number your view needs:
    // - HOT: total brew water (grams) = coffeeGrams * ratio
    // - ICED: target beverage milliliters
    @Guide(description: "If style == hot, total water grams. If iced, target beverage ml.")
    public var primaryVolume: Double
    
    // Optional: display-only context (not needed by BrewingView)
    public var notes: String
}

extension BrewPlan.PartiallyGenerated {
    func asComplete() -> BrewPlan? {
        guard
            let style,
            let balanceLevel,
            let strengthLevel,
            let coffeeGrams,
            let ratio,
            let pourIntervalSec,
            let primaryVolume
        else { return nil }
        
        return BrewPlan(
            style: style,
            balanceLevel: balanceLevel,
            strengthLevel: strengthLevel,
            coffeeGrams: coffeeGrams,
            ratio: ratio,
            pourIntervalSec: pourIntervalSec,
            primaryVolume: primaryVolume,
            notes: notes ?? ""
        )
    }
}
