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
    @Binding var coffeeBalance: Int
    @Binding var coffeeStrength: Int
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
    
    var body: some View {
        ZStack(alignment: .top) {
            HStack {
                Button {
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
                        // Play/Pause Button
                        Button(action: {
                            timerIsActive ? pauseTimer() : startTimer()
                        }) {
                            Image(systemName: timerIsActive ? "pause.circle" : "play.circle")
                                .font(.system(size: 50))
                        }
                        
                        HStack(alignment: .center) {
                            Spacer()
                            
                            // Next Button
                            Button(action: {
                                nextTimer()
                            }) {
                                Image(systemName: "forward.fill")
                                    .font(.system(size: 50))
                            }
                        }
                        .opacity(currentStep == 0 ? 0 : 1)
                    } else {
                        // Done Button
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("Done")
                                .font(.title2)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            calculateNumberOfSteps()
            calculateAmountOfPour()
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
        .onChange(of: currentStep) { _ in
            updateCircularTitleText()
            updateTotalRemainingTime()
            if currentStep % 2 != 0 {
                updateTotalCoffeeAmount()
            }
        }
    }
    
    // Calculate the steps
    func calculateNumberOfSteps() {
        if brewingMode == .iced {
            numberOfSteps = 6
        } else {
            switch coffeeStrength {
            case 0: numberOfSteps = 8
            case 1: numberOfSteps = 10
            case 2: numberOfSteps = 12
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
            case 0:
                firstPour = groundCoffeeAmount * 2.5
                secondPour = groundCoffeeAmount * 3.5
            case 1:
                firstPour = groundCoffeeAmount * 3
                secondPour = groundCoffeeAmount * 3
            case 2:
                firstPour = groundCoffeeAmount * 3.5
                secondPour = groundCoffeeAmount * 2.5
            default:
                break
            }
            
            switch coffeeStrength {
            case 0:
                remainingPours = six / 2
            case 1:
                remainingPours = six / 3
            case 2:
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
        if currentStep != numberOfSteps {
            if currentStep % 2 != 0 {
                remainingTime = 12
                progressRemainingTime = 12
                totalRemainingTime = 12
            } else {
                remainingTime = TimeInterval(pourInterval - 12)
                progressRemainingTime = TimeInterval(pourInterval - 12)
                totalRemainingTime = TimeInterval(pourInterval - 12)
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
                coffeeBalance: .constant(0),
                coffeeStrength: .constant(0),
                coffeeRatio: .constant(15),
                pourInterval: .constant(30))
}
