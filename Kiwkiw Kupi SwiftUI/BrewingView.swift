//
//  BrewingView.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 20/11/24.
//

import SwiftUI

struct BrewingView: View {
    
    @Binding var isPresented: Bool
    @Binding var brewingMode: ModeSegments
    @Binding var coffeeAmount: Double
    @Binding var coffeeBalance: BrewBalance
    @Binding var coffeeStrength: BrewStrength
    @Binding var coffeeRatio: Double
    @Binding var pourInterval: Int
    
    @State var circularTitleText = "Get Ready"
    @State var numberOfSteps = 8
    @State var currentStep = 0
    
    @State var elapsedTime: TimeInterval = 0
    @State var remainingTime: TimeInterval = 5 // Total time in seconds
    @State var totalRemainingTime: TimeInterval = 5 // Total countdown duration
    @State var progress: Double = 1.0 // Circle progress (1.0 = full)
    @State var timerIsActive: Bool = false
    @State var progressRemainingTime: TimeInterval = 5
    
    @State var firstPour: Double = 0
    @State var secondPour: Double = 0
    @State var remainingPours: Double = 0
    @State var totalCoffeeAmount: Double = 0
    
    @State var isAlertShown = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let progressTimer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    fileprivate func cancelButton() -> some View {
        return Button {
            isAlertShown = true
        } label: {
            Image(systemName: "xmark")
            Text("Cancel")
        }
        .opacity(currentStep == numberOfSteps ? 0 : 1)
        .alert("Cancel the Brew?", isPresented: $isAlertShown) {
            Button("No", role: .cancel) {
                isAlertShown = false
            }
            
            Button("Yes", role: .destructive) {
                isAlertShown = false
                isPresented = false
            }
        }
    }
    
    // Play/Pause Button
    fileprivate func playPauseButton() -> Button<some View> {
        return Button(action: {
            timerIsActive ? pauseTimer() : startTimer()
        }) {
            Image(systemName: timerIsActive ? "pause.fill" : "play.fill")
                .font(.largeTitle)
                .padding(8)
        }
    }
    
    // Next Button
    fileprivate func nextButton() -> Button<some View> {
        return Button(action: {
            nextTimer()
        }) {
            Image(systemName: "forward.fill")
                .font(.largeTitle)
                .padding(8)
        }
    }
    
    // Done Button
    fileprivate func doneButton() -> Button<some View> {
        return Button(action: {
            isPresented = false
        }) {
            Text("Done")
                .font(.title2)
                .fontWeight(.medium)
                .padding(8)
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            HStack {
                if #available(iOS 26.0, *) {
                    cancelButton()
                        .buttonStyle(.glass)
                        .foregroundStyle(.red)
                } else {
                    cancelButton()
                        .foregroundStyle(.red)
                }
                Spacer()
            }
            .padding()
            
            VStack {
                Text("\(currentStep) of \(numberOfSteps)")
                    .padding(.bottom, 8)
                
                Text("Total Time")
                    .font(.footnote)
                
                Text(formatTime(elapsedTime))
                    .font(.title)
                
                Spacer()
                
                CountdownTimerCircleView(titleText: $circularTitleText,
                                         remainingTime: $remainingTime,
                                         progress: $progress,
                                         timerIsActive: $timerIsActive)
                
                Text("\(Int(totalCoffeeAmount.rounded()))g total")
                
                Spacer()
                
                ZStack {
                    if currentStep != numberOfSteps {
                        if #available(iOS 26.0, *) {
                            playPauseButton()
                                .buttonStyle(.glassProminent)
                        } else {
                            playPauseButton()
                                .buttonStyle(.borderedProminent)
                        }
                        
                        HStack(alignment: .center) {
                            Spacer()
                            if #available(iOS 26.0, *) {
                                nextButton()
                                    .buttonStyle(.glassProminent)
                            } else {
                                nextButton()
                                    .buttonStyle(.borderedProminent)
                            }
                        }
                        .opacity(currentStep == 0 ? 0 : 1)
                    } else {
                        if #available(iOS 26.0, *) {
                            doneButton()
                                .buttonStyle(.glassProminent)
                        } else {
                            doneButton()
                                .buttonStyle(.borderedProminent)
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            calculateNumberOfSteps()
            calculateAmountOfPour()
            
            // Makes the screen stays awake
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            // Makes the screen follows back auto lock settings
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onReceive(timer) { _ in
            if timerIsActive {
                updateTimer()
            }
        }
        .onReceive(progressTimer) { _ in
            if timerIsActive {
                updateProgressTimer()
            }
        }
        .onChange(of: currentStep, { _, _ in
            updateCircularTitleText()
            updateTotalRemainingTime()
            if currentStep % 2 != 0 {
                updateTotalCoffeeAmount()
            }
        })
    }
    
    // Calculate the steps
    func calculateNumberOfSteps() {
        if brewingMode == .iced {
            numberOfSteps = 6
        } else {
            switch coffeeStrength {
            case .light: numberOfSteps = 8
            case .medium: numberOfSteps = 10
            case .strong: numberOfSteps = 12
            default: break
            }
        }
    }
    
    // Calculate the pours
    func calculateAmountOfPour() {
        if brewingMode == .iced {
            let groundCoffeeAmount = coffeeAmount / 15
            firstPour = groundCoffeeAmount * 2.5
            secondPour = groundCoffeeAmount * 3.5
            remainingPours = groundCoffeeAmount * 3
        } else {
            let groundCoffeeAmount = coffeeAmount / coffeeRatio
            let six = (coffeeAmount * 60) / 100
            
            switch coffeeBalance {
            case .sweeter:
                firstPour = groundCoffeeAmount * 2.5
                secondPour = groundCoffeeAmount * 3.5
            case .standard:
                firstPour = groundCoffeeAmount * 3
                secondPour = groundCoffeeAmount * 3
            case .brighter:
                firstPour = groundCoffeeAmount * 3.5
                secondPour = groundCoffeeAmount * 2.5
            default:
                break
            }
            
            switch coffeeStrength {
            case .light:
                remainingPours = six / 2
            case .medium:
                remainingPours = six / 3
            case .strong:
                remainingPours = six / 4
            default:
                break
            }
        }
    }
    
    // Update the circular title
    func updateCircularTitleText() {
        if currentStep != numberOfSteps {
            if currentStep % 2 != 0 {
                switch currentStep {
                case 1: circularTitleText = "Pour \(Int(firstPour.rounded()))g"
                case 3: circularTitleText = "Pour \(Int(secondPour.rounded()))g"
                default: circularTitleText = "Pour \(Int(remainingPours.rounded()))g"
                }
            } else {
                circularTitleText = "Let it drip"
            }
        } else {
            circularTitleText = "Remove dripper when finished"
        }
    }
    
    // Update total coffee amount
    func updateTotalCoffeeAmount() {
        switch currentStep {
        case 1: totalCoffeeAmount += firstPour
        case 3: totalCoffeeAmount += secondPour
        default: totalCoffeeAmount += remainingPours
        }
    }
    
    // Update total remaining time
    func updateTotalRemainingTime() {
        let pouringTime = brewingMode != .iced ? 12 : 10
        if currentStep != numberOfSteps {
            if currentStep % 2 != 0 {
                remainingTime = TimeInterval(pouringTime)
                progressRemainingTime = TimeInterval(pouringTime)
                totalRemainingTime = TimeInterval(pouringTime)
            } else {
                remainingTime = TimeInterval(pourInterval - pouringTime)
                progressRemainingTime = TimeInterval(pourInterval - pouringTime)
                totalRemainingTime = TimeInterval(pourInterval - pouringTime)
            }
        } else {
            remainingTime = 0
            progressRemainingTime = 0
            totalRemainingTime = 0
        }
    }
    
    // Start the timer
    func startTimer() {
        timerIsActive = true
    }
    
    // Pause the timer
    func pauseTimer() {
        timerIsActive = false
    }
    
    // Stop the timer
    func stopTimer() {
        timerIsActive = false
    }
    
    // Reset the timer
    func resetTimer() {
        timerIsActive = false
        remainingTime = totalRemainingTime
        progressRemainingTime = totalRemainingTime
        progress = 1.0
    }
    
    // Skip the timer
    func nextTimer() {
        if currentStep != numberOfSteps {
            remainingTime = totalRemainingTime
            progressRemainingTime = totalRemainingTime
            progress = 1.0
            performCompletionAction()
        } else {
            progress = 1.0
        }
    }
    
    // Format the elapsed time into mm:ss
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func updateTimer() {
        // Update elapsed time
        if currentStep > 0 {
            elapsedTime += 1
        }
        
        // Update remaning time
        if remainingTime > 0 {
            remainingTime -= 1
        }
    }
    
    func updateProgressTimer() {
        if progressRemainingTime > 0 {
            progressRemainingTime -= 0.01
            progress = progressRemainingTime / totalRemainingTime
        } else {
            nextTimer()
        }
    }
    
    func performCompletionAction() {
        currentStep += 1
    }
}

#Preview {
    BrewingView(isPresented: .constant(true),
                brewingMode: .constant(.simple),
                coffeeAmount: .constant(300),
                coffeeBalance: .constant(.standard),
                coffeeStrength: .constant(.medium),
                coffeeRatio: .constant(15),
                pourInterval: .constant(30))
}
