//
//  ChatView.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 19/09/25.
//

import SwiftUI

@available(iOS 26.0, *)
struct ChatView: View {
    @StateObject private var vm = ChatViewModel()
    @Environment(\.openURL) private var openURL
    @State private var input = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(vm.messages) { m in
                            // Right for user, left for AI
                            md(m.text)
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill((m.role == .user) ? Color.blue.opacity(0.12) : Color.gray.opacity(0.12))
                                )
                                .frame(maxWidth: .infinity, alignment: (m.role == .user) ? .trailing : .leading)
                                .multilineTextAlignment((m.role == .user) ? .trailing : .leading)
                                .id(m.id)
                        }
                        
                        if !vm.streamingText.isEmpty {
                            md(vm.streamingText + "▌")
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.12)))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                        }
                        
                        if let final = vm.confirmedPlan {
                            BrewPlanCard(
                                plan: final,
                                onUse: {
                                    let params = BrewingParams(plan: final)
                                    openURL(.brewURL(from: params))
                                }
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                        
                        if let err = vm.errorText {
                            Text(err).foregroundStyle(.red).font(.footnote)
                        }
                        
                        // --- 16pt bottom padding anchor ---
                        Color.clear
                            .frame(height: 8)
                            .id("bottomPad")
                    }
                    .padding(.horizontal)
                }
                .onChange(of: vm.streamingText, { _, _ in scrollToBottom(proxy) })
                .onChange(of: vm.streamingPlan?.primaryVolume, { _, _ in scrollToBottom(proxy) })
                .onChange(of: vm.messages.last?.id, { _, _ in scrollToBottom(proxy) })
            }
            
            // Input row
            HStack {
                TextField("Ask about coffee…", text: $input, axis: .vertical)
                    .submitLabel(.send)
                    .onSubmit { send() }
                Button("Send") { send() }
                    .buttonStyle(.glassProminent)
                Menu("⋯") {
                    Button("Suggest 4:6 Recipe") { input = "Suggest 4:6 Recipe"; send() }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    clearChats()
                }) {
                    Text("Clear")
                }
            }
        }
    }
    
    private func clearChats() {
        vm.cancel()
        vm.messages.removeAll()
        input = ""
    }
    
    // Clear and chain suggest AFTER the reply finishes
    private func send() {
        let msg = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !msg.isEmpty else { return }
        input = ""
        vm.send(msg) {
            // Only auto-propose if we're not currently awaiting confirmation (fresh ask)
            if !vm.isAwaitingConfirmation {
                vm.suggestRecipe()
            }
        }
    }
    
    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.2)) {
            proxy.scrollTo("bottomPad", anchor: .bottom)
        }
    }
    
    private func md(_ s: String) -> Text {
        // Use inline markdown parsing so **bold** works inside a single line/bubble.
        if let a = try? AttributedString(
            markdown: s,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) {
            return Text(a)
        } else {
            return Text(s) // graceful fallback
        }
    }
}
