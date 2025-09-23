//
//  BrewPlan.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 18/09/25.
//

import Foundation
import FoundationModels

@available(iOS 26.0, *)
@Generable
public enum BrewStyle: String, Codable, CaseIterable {
    case hot, iced
}

@Generable
public enum BrewBalance: String, CaseIterable, Codable {
    case sweeter = "Sweeter"
    case standard = "Standard"
    case brighter = "Brighter"
}

@Generable
public enum BrewStrength: String, CaseIterable, Codable {
    case light = "Light"
    case medium = "Medium"
    case strong = "Strong"
}

@Generable
public enum BrewRoast: String, CaseIterable, Codable {
    case lightRoast = "Light Roast"
    case mediumRoast = "Medium Roast"
    case darkRoast = "Dark Roast"
}

@available(iOS 26.0, *)
@Generable
public struct BrewPlan: Equatable, Codable {
    // Decide hot vs iced from chat context (iced → Japanese iced / flash brew).
    @Guide(description: "Hot or iced; choose iced if user asks for iced/Japanese iced/flash brew.")
    public var style: BrewStyle
    
    @Guide(description: "Sweeter, standard/balanced, or brighter; default to standard/balanced.")
    public var balanceLevel: BrewBalance
    
    @Guide(description: "Light, medium, or strong; default to medium.")
    public var strengthLevel: BrewStrength
    
    @Guide(description: "Light roast, medium roast, or dark roast; default to medium roast.")
    public var roastLevel: BrewRoast
    
    // Quantities
    @Guide(description: "Coffee dose in grams.", .range(10.0...40.0))
    public var coffeeGrams: Double
    
    @Guide(description: "Water ratio, e.g. 15.0 means 1:15.", .range(13.0...18.0))
    public var ratio: Double
    
    @Guide(description: "Total pours needed", .range(3...6))
    public var totalPours: Int
    
    @Guide(description: "Seconds between pours.", .range(15...45))
    public var pourIntervalSec: Int
    
    @Guide(description: "Total time needed; totalTime = totalPours * pourIntervalSec")
    public var totalTime: TimeInterval
    
    @Guide(description: "Water temperature needed. Light Roast = 93°C, Medium Roast = 88°C, Dark Roast = 83°C.")
    public var waterTemp: Int
    
    // If style == ICED
    @Guide(description: "Ice needed in grams; 40% from primaryVolume.")
    public var iceAmount: Int
    
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
            let roastLevel,
            let coffeeGrams,
            let ratio,
            let pourIntervalSec,
            let totalPours,
            let totalTime,
            let waterTemp,
            let iceAmount,
            let primaryVolume,
            let notes
        else { return nil }
        
        return BrewPlan(
            style: style,
            balanceLevel: balanceLevel,
            strengthLevel: strengthLevel,
            roastLevel: roastLevel,
            coffeeGrams: coffeeGrams,
            ratio: ratio,
            totalPours: totalPours,
            pourIntervalSec: pourIntervalSec,
            totalTime: totalTime,
            waterTemp: waterTemp,
            iceAmount: iceAmount,
            primaryVolume: primaryVolume,
            notes: notes
        )
    }
}

extension BrewPlan {
    /// Enforce internal consistency and sane ranges.
    func normalized() -> BrewPlan {
        var p = self

        // Clamp ranges you already guide (belt & suspenders)
        p.ratio         = min(max(p.ratio, 13.0), 18.0)
        p.pourIntervalSec = min(max(p.pourIntervalSec, 15), 45)

        // Primary volume rules
        let expected = p.coffeeGrams * p.ratio // Double
        switch p.style {
        case .hot:
            // total brew water (g)
            p.primaryVolume = expected.rounded()

        case .iced:
            // Japanese iced → target beverage ml (same numeric as dose*ratio)
            // If the model put a "water-only" amount here, overwrite it.
            p.primaryVolume = expected.rounded()
        }

        return p
    }
}
