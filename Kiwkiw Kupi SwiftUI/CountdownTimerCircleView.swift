//
//  CountdownTimerCircleView.swift
//  Kiwkiw Kupi SwiftUI
//
//  Created by Rayhan Faluda on 21/11/24.
//

import SwiftUI

struct CountdownTimerCircleView: View {
    
    @Binding var titleText: String
    @Binding var remainingTime: TimeInterval
    @Binding var progress: Double
    @Binding var timerIsActive: Bool
    
    let totalTime: Double = 10 // Total countdown duration
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            ZStack {
                // Background Circle
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                    .frame(width: 300, height: 300)
                
                // Progress Circle
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(
                        Color.blue,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(Angle(degrees: -90))
                    .frame(width: 300, height: 300)
                    .animation(.linear(duration: 0.1), value: progress)
                
                VStack {
                    // Coffee Text
                    Text(titleText)
                        .font(.title)
                        .multilineTextAlignment(.center)
                    
                    // Timer Text
                    Text(formatTime(remainingTime))
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                }
                .frame(width: 260)
            }
        }
        .padding()
    }
    
    // Format the elapsed time into mm:ss
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

//#Preview {
//    CountdownTimerCircleView(remainingTime: .constant(10), progress: .constant(0.5), timerIsActive: .constant(true))
//}
