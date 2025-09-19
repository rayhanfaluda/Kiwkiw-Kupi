//
//  ChatViewModel.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 19/09/25.
//

import SwiftUI
import FoundationModels

// ChatViewModel.swift
@MainActor
final class ChatViewModel: ObservableObject {
    enum Role { case user, assistant }
    struct Message: Identifiable, Equatable { let id = UUID(); let role: Role; var text: String }
    
    @Published var messages: [Message] = []
    @Published var streamingText: String = ""
    @Published var streamingPlan: BrewPlan.PartiallyGenerated?   // still used internally
    @Published var finalPlan: BrewPlan?                          // candidate plan (not yet confirmed)
    @Published var confirmedPlan: BrewPlan?                      // ✅ show card only for this
    @Published var isReplyStreaming = false
    @Published var isPlanStreaming  = false
    @Published var isAwaitingConfirmation = false                // ✅ gate for confirmation
    @Published var errorText: String?
    
    private let assistant = CoffeeAssistant()
    private var activeTask: Task<Void, Never>?
    private var lastUserMessage: String = ""
    
    // Public: normal send entrypoint
    func send(_ text: String) {
        // If we’re waiting for yes/no/changes, that flow stays the same:
        if isAwaitingConfirmation { handleConfirmation(text); return }
        
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        cancel()
        errorText = nil
        lastUserMessage = trimmed
        messages.append(.init(role: .user, text: trimmed))
        
        // 🔎 Classify the intent first
        activeTask = Task {
            do {
                let intent = try await assistant.classifyIntent(trimmed)
                
                if intent.intent == .recipe {
                    // ✅ Command path: do NOT stream chat text with numbers
                    messages.append(.init(role: .assistant, text: "Got it — building a 4:6 recipe…"))
                    suggestRecipe()                     // single source of truth
                    return
                }
                
                // 💬 Chitchat path: stream a normal reply (no numbers, per instructions)
                isReplyStreaming = true
                streamingText = ""
                let stream = try await assistant.streamChatReply(trimmed)
                for try await snap in stream { streamingText = snap.content.text ?? "" }
                messages.append(.init(role: .assistant, text: streamingText))
                isReplyStreaming = false
                streamingText = ""
            } catch {
                errorText = error.localizedDescription
                isReplyStreaming = false
            }
        }
    }
    
    func suggestRecipe(hint: String? = nil) {
        if isPlanStreaming { return }
        cancel()
        isPlanStreaming = true
        errorText = nil
        streamingPlan = nil
        finalPlan = nil
        
        var prompt = """
            Based on the most recent user request:
            \"\(lastUserMessage)\"
            Propose a 4:6 V60 recipe. If they asked for iced/flash brew, set style=iced and use target beverage ml; otherwise style=hot. Keep outputs realistic and within schema.
            """
        if let hint, !hint.isEmpty { prompt += "\n\nAdditionally, apply these constraints:\n\(hint)" }
        
        activeTask = Task {
            do {
                let stream = try await assistant.streamBrewPlan(prompt)
                for try await snapshot in stream { streamingPlan = snapshot.content }
                finalPlan = streamingPlan?.asComplete()
                if let plan = finalPlan {
                    // Approval bubble derived from the structured plan (no drift)
                    messages.append(.init(role: .assistant, text: approvalPrompt(for: plan)))
                    isAwaitingConfirmation = true
                }
            } catch {
                errorText = error.localizedDescription
            }
            isPlanStreaming = false
        }
    }
    
    func cancel() { activeTask?.cancel(); activeTask = nil }
    
    func clearChat(resetSession: Bool = true) {
        // stop any generation first
        cancel()
        
        // wipe UI state
        messages.removeAll()
        streamingText = ""
        streamingPlan = nil
        finalPlan = nil
        confirmedPlan = nil
        isReplyStreaming = false
        isPlanStreaming  = false
        isAwaitingConfirmation = false
        errorText = nil
        lastUserMessage = ""
        
        // optionally rebuild the LLM session (forget context)
        if resetSession {
            assistant.reset()
        }
    }
    
    // Interpret the user's yes/no/changes while awaiting confirmation
    private func handleConfirmation(_ userText: String) {
        messages.append(.init(role: .user, text: userText))
        cancel()
        activeTask = Task {
            do {
                let decision = try await assistant.classifyConfirmation(userText)
                switch decision.action {
                case .confirm:
                    guard let plan = finalPlan else {
                        messages.append(.init(role: .assistant, text: "I lost the last recipe—let me propose it again."))
                        isAwaitingConfirmation = false
                        suggestRecipe() // rebuild
                        return
                    }
                    confirmedPlan = plan
                    isAwaitingConfirmation = false
                    messages.append(.init(role: .assistant, text: "Great! I’ve locked in the recipe—tap **Start Brewing** when ready."))
                    
                case .revise:
                    // Use normalized details as a hint; if empty, fall back to the raw user text
                    let nudge = decision.details.isEmpty ? userText : decision.details
                    isAwaitingConfirmation = false
                    messages.append(.init(role: .assistant, text: "Sure—updating the recipe…"))
                    lastUserMessage = (lastUserMessage + "\n" + nudge)
                    suggestRecipe(hint: nudge)
                    
                case .cancel:
                    isAwaitingConfirmation = false
                    finalPlan = nil
                    streamingPlan = nil
                    messages.append(.init(role: .assistant, text: "No problem—recipe canceled. Tell me when you want to try again."))
                    
                case .unclear:
                    messages.append(.init(role: .assistant, text: "I didn’t catch that—say **Yes** to accept, or tell me what to change (e.g., “stronger”, “ratio 1:16”, “iced 300ml”)."))
                }
            } catch {
                errorText = error.localizedDescription
                // Fallback heuristic if LLM classification fails
                if userText.lowercased().contains("yes") || userText.lowercased().contains("looks good") {
                    if let plan = finalPlan {
                        confirmedPlan = plan
                        isAwaitingConfirmation = false
                        messages.append(.init(role: .assistant, text: "Awesome—recipe confirmed."))
                    }
                } else {
                    isAwaitingConfirmation = false
                    suggestRecipe(hint: userText)
                }
            }
        }
    }
    
    // Small, human-friendly summary that the AI "says" when asking for approval
    private func approvalPrompt(for plan: BrewPlan) -> String {
        let dose = String(format: "%.1f", plan.coffeeGrams)
        let ratio = String(format: "%.1f", plan.ratio)
        let interval = plan.pourIntervalSec
        switch plan.style {
        case .iced:
            let target = Int(plan.primaryVolume.rounded())
            return "Here’s my 4:6 (Japanese iced) suggestion: **\(dose)g**, target **\(target)ml**, ratio **1:\(ratio)**, interval **\(interval)s**. Does this look good? Say **Yes** to confirm or tell me what to change."
        case .hot:
            let total = Int(plan.primaryVolume.rounded())
            return "Here’s my 4:6 suggestion: **\(dose)g**, total **\(total)ml**, ratio **1:\(ratio)**, interval **\(interval)s**. Happy with this? Say **Yes** to confirm or tell me what to tweak."
        }
    }
    
    private func isRecipeCommand(_ text: String) -> Bool {
        let t = text.lowercased()
        // add patterns you like
        return t.contains("4:6 recipe")
        || t.contains("suggest recipe")
        || t.contains("suggest a 4:6")
        || t.contains("propose 4:6")
        || t == "suggest 4:6" || t == "suggest 4:6 recipe"
    }
}
