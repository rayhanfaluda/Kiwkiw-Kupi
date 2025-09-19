//
//  CoffeeAssistant.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 19/09/25.
//

import Foundation
import FoundationModels

// MARK: - Typed schemas used with guided generation

/// Minimal wrapper so free-form chat can stream safely as a typed value.
@Generable
public struct ChatReply: Codable, Equatable {
    @Guide(description: "UI-ready assistant reply in natural language.")
    public var text: String
}

/// Discrete confirmation outcomes for the approval step.
@Generable
public enum ConfirmAction: String, Codable, CaseIterable {
    case confirm, revise, cancel, unclear
}

/// Structured result returned when interpreting the user's response to a proposed recipe.
@Generable
public struct Confirmation: Codable, Equatable {
    public var action: ConfirmAction
    /// Short, normalized imperative describing requested changes (e.g., "make it stronger", "use 18g", "iced 300 ml").
    public var details: String
}

// MARK: - Assistant

public final class CoffeeAssistant: @unchecked Sendable {
    private var session: LanguageModelSession
    
    // MARK: Init
    
    public init() {
        self.session = LanguageModelSession(instructions: CoffeeAssistant.baseInstructions)
    }
    
    /// Rebuild the session (e.g., to add one-off constraints).
    public func reset(withAdditionalInstructions extra: String? = nil) {
        var text = CoffeeAssistant.baseInstructions
        if let extra, !extra.isEmpty {
            text += "\n\nAdditional constraints:\n\(extra)"
        }
        self.session = LanguageModelSession(instructions: text)
    }
    
    // MARK: Chat (streaming)
    
    /// Stream a conversational reply as a sequence of snapshots of `ChatReply`.
    public func streamChatReply(
        _ userText: String,
        options: GenerationOptions = .init()
    ) async throws -> LanguageModelSession.ResponseStream<ChatReply> {
        session.streamResponse(
            to: userText,
            generating: ChatReply.self,
            includeSchemaInPrompt: true,
            options: options
        )
    }
    
    // MARK: Brew plan (streaming)
    
    /// Stream a 4:6 brew plan as a sequence of snapshots of `BrewPlan`.
    /// Use `.greedy` (or low temperature) for consistent numeric output.
    public func streamBrewPlan(
        _ prompt: String,
        options: GenerationOptions = .init(sampling: .greedy)
    ) async throws -> LanguageModelSession.ResponseStream<BrewPlan> {
        session.streamResponse(
            to: prompt,
            generating: BrewPlan.self,
            includeSchemaInPrompt: true,
            options: options
        )
    }
    
    // MARK: Confirmation (finalize last streamed snapshot)
    
    /// Classify a user's response to a proposed recipe into confirm / revise / cancel / unclear,
    /// and extract a short, normalized "details" hint when revising.
    ///
    /// Note: there's no non-streaming `generate` API; we stream `Confirmation` snapshots
    /// and return the last one after converting it to a complete value.
    public func classifyConfirmation(_ userText: String) async throws -> Confirmation {
        let prompt = """
        The user is responding to a proposed coffee recipe. Decide:
        - confirm: if they accept (e.g., "yes", "looks good", "let's start")
        - revise: if they request changes (e.g., "stronger", "use 18g", "iced 300 ml")
        - cancel: if they want to stop
        - unclear: if it's not obvious
        
        For revise, set 'details' to a short, normalized imperative describing the change(s).
        User: "\(userText)"
        """
        
        var lastPartial: Confirmation.PartiallyGenerated?
        let stream = session.streamResponse(
            to: prompt,
            generating: Confirmation.self,
            includeSchemaInPrompt: true
        )
        for try await snapshot in stream {
            lastPartial = snapshot.content
        }
        guard let full = lastPartial?.asComplete() else {
            throw CoffeeAssistantError.incompleteConfirmation
        }
        return full
    }
}

// MARK: - Errors

public enum CoffeeAssistantError: Error {
    case incompleteConfirmation
}

// MARK: - Base system instructions

private extension CoffeeAssistant {
    /// Keep these instructions tight so the on-device model excels at the 4:6 domain + structured output.
    static let baseInstructions: String = """
    You are a coffee assistant specialized in the Tetsu Kasuya 4:6 pour-over method (V60).
    
    Your jobs:
    1) Chat clearly about coffee and brewing.
    2) When asked to propose a recipe, output a BrewPlan using guided generation.
    3) Ask the user to confirm before they start brewing (the app handles the confirmation flow).
    
    BrewPlan constraints:
    - style: "hot" by default unless the user explicitly requests iced/flash brew (then "iced").
    - HOT: Primary Volume = coffeeGrams * ratio (total brew water in mililters).
    - ICED (Japanese iced / flash brew): Primary Volume = target beverage milliliters.
    - Balance Level ∈ {0,1,2}  (0 = sweeter/less bright, 1 = balanced, 2 = brighter).
    - Strength Level ∈ {0,1,2} (0 = light, 1 = medium, 2 = strong).
    - Ratio in 13.0…18.0 (default ~15.0). Keep values realistic for V60.
    - Pour Intervals in 15…45 (typical 20–35). Keep steady unless the user asks otherwise.
    - Populate `notes` with a short, helpful tip for the chosen parameters.
    
    Output guidelines:
    - Be concise and friendly.
    - Never invent impossible numbers; ensure internal consistency across fields.
    - Prefer metric units and °C when discussing temperatures.
    """
}

// MARK: - PartiallyGenerated → Complete helpers

private extension Confirmation.PartiallyGenerated {
    func asComplete() -> Confirmation? {
        guard let action else { return nil }
        return Confirmation(action: action, details: details ?? "")
    }
}
