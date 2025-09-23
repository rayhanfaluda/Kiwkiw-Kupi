//
//  DeepLink.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 19/09/25.
//

import Foundation

struct BrewingParams: Equatable, Codable, Identifiable {
    var id = UUID()
    var brewingMode: ModeSegments
    var coffeeAmount: Double
    var coffeeBalance: BrewBalance
    var coffeeStrength: BrewStrength
    var coffeeRoast: BrewRoast
    var coffeeRatio: Double
    var pourInterval: Int
}

extension BrewingParams {
    @available(iOS 26.0, *)
    init(plan: BrewPlan) {
        if plan.style == .iced {
            // BrewingView expects: .iced + coffeeAmount = target ml
            self.brewingMode  = .iced
            self.coffeeAmount = plan.primaryVolume
        } else {
            // BrewingView treats any non-iced the same; use .simple
            self.brewingMode  = .simple
            self.coffeeAmount = plan.primaryVolume // total water grams
        }
        self.coffeeBalance  = plan.balanceLevel
        self.coffeeStrength = plan.strengthLevel
        self.coffeeRoast    = plan.roastLevel
        self.coffeeRatio    = plan.ratio
        self.pourInterval   = plan.pourIntervalSec
    }
}

extension URL {
    static func brewURL(from p: BrewingParams) -> URL {
        var comps = URLComponents()
        comps.scheme = "kiwkiw"
        comps.host = "brew"
        comps.queryItems = [
            .init(name: "mode", value: p.brewingMode.rawValue),
            .init(name: "coffeeAmount", value: String(p.coffeeAmount)),
            .init(name: "balance", value: p.coffeeBalance.rawValue),
            .init(name: "strength", value: p.coffeeStrength.rawValue),
            .init(name: "roast", value: p.coffeeRoast.rawValue),
            .init(name: "ratio", value: String(p.coffeeRatio)),
            .init(name: "pourInterval", value: String(p.pourInterval)),
        ]
        return comps.url!
    }
}
