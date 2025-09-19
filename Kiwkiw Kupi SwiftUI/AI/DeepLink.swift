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
    var coffeeBalance: Int
    var coffeeStrength: Int
    var coffeeRatio: Double
    var pourInterval: Int
}

extension BrewingParams {
    @available(iOS 26.0, *)
    init(plan: BrewPlan) {
        let bal = max(0, min(2, plan.balanceLevel))
        let str = max(0, min(2, plan.strengthLevel))

        if plan.style == .iced {
            // BrewingView expects: .iced + coffeeAmount = target ml
            self.brewingMode  = .iced
            self.coffeeAmount = plan.primaryVolume
        } else {
            // BrewingView treats any non-iced the same; use .simple
            self.brewingMode  = .simple
            self.coffeeAmount = plan.primaryVolume // total water grams
        }
        self.coffeeBalance = bal
        self.coffeeStrength = str
        self.coffeeRatio   = plan.ratio
        self.pourInterval  = plan.pourIntervalSec
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
            .init(name: "balance", value: String(p.coffeeBalance)),
            .init(name: "strength", value: String(p.coffeeStrength)),
            .init(name: "ratio", value: String(p.coffeeRatio)),
            .init(name: "pourInterval", value: String(p.pourInterval)),
        ]
        return comps.url!
    }
}
