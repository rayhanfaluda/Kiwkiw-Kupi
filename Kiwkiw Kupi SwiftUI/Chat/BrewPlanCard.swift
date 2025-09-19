//
//  BrewPlanCard.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 19/09/25.
//

import SwiftUI

struct BrewPlanCard: View {
    let plan: BrewPlan
    let onUse: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(plan.style == .iced ? "4:6 (Japanese Iced)" : "4:6 Recipe")
                .font(.headline)
            
            summary(plan)
                .font(.subheadline)
            
            Button("Start Brewing", action: onUse)
                .buttonStyle(.glassProminent)
        }
        .padding(12)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    // Return Text so we can bold the dose
    private func summary(_ p: BrewPlan) -> Text {
        switch p.style {
        case .iced:
            let dose = Text("\(p.coffeeGrams, specifier: "%.1f")") + Text(" g")
            let target = Int(p.primaryVolume.rounded())
            return dose
            + Text(" · target ") + Text("\(target)") + Text(" ml")
            + Text(" · target ") + Text("\(target)") + Text(" ml")
            + Text(" · 1:") + Text("\(p.ratio, specifier: "%.1f")")
            + Text(" · interval ") + Text("\(p.pourIntervalSec)") + Text("s")
        case .hot:
            let dose = Text("\(p.coffeeGrams, specifier: "%.1f")") + Text(" g")
            let total = Int(p.primaryVolume.rounded())
            return dose
            + Text(" · total ") + Text("\(total)") + Text(" g")
            + Text(" · 1:") + Text("\(p.ratio, specifier: "%.1f")")
            + Text(" · interval ") + Text("\(p.pourIntervalSec)") + Text("s")
        }
    }
}

//#Preview {
//    BrewPlanCard(plan: <#BrewPlan#>, onUse: <#() -> Void#>)
//}
