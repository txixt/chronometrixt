//
//  TimerView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/15/26.
//

import SwiftUI
import SwiftData

struct TimerView: View {
    @Query private var timerData: [MetricAlarm]
    @Environment(\.modelContext) private var context
    @Bindable var gov: Governor
    
    var body: some View {
        VStack {
            Spacer()
            if !gov.ac.activeTimers.isEmpty {
                ForEach(gov.ac.activeTimers, id: \.id) { timer in
                    ZStack {
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(timer.durationTxt)
                                    .font(.title2).bold()
                                Text(timer.gregDurationTxt)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: { gov.ac.cancelTimer(timer: timer)}) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.primary).bold()
                                    .shadow(radius: 3)
                            }
                            
                            Text(timer.countdownTxt)
                                .font(.title2).bold()
                                .frame(width: 100, height: 33)
                                .foregroundStyle(.primary)
                                .background(RoundedRectangle(cornerRadius: 10).fill(.gray).opacity(0.2))
                                .shadow(radius: 5)
                        }
                    }
                }
            }
            
            if !gov.ac.timers.isEmpty {
                ForEach(gov.ac.timers, id: \.id) { timer in
                    ZStack {
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(timer.durationTxt)
                                    .font(.title2).bold()
                                Text(timer.gregDurationTxt)
                            }
                            
                            Spacer()
                            
                            Button(action: { gov.ac.destroyTimer(timer: timer) }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.primary).bold()
                                    .shadow(radius: 3)
                            }
                            
                            Button(action: { startTimer(oldTimer: timer) }) {
                                Image(systemName: "arrow.3.trianglepath").bold()
                                    .foregroundStyle(.background)
                                    .frame(width: 100, height: 33)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(.metricOrange))
                            }
                        }
                    }
                }
            }
            
            if !gov.ac.activeTimers.isEmpty || !gov.ac.timers.isEmpty {
                MetrixtSubdivider()
            }
            
            HStack(spacing: 0) {
                Spacer()
                
                Text("new timer:").bold()
                
                Picker("hour", selection: $gov.ac.timerHour) {
                    ForEach(0...9, id: \.self) { i in
                        Text(String(i)).tag(i)
                            .font(.title).bold()
                    }
                }
                .frame(width: 60)
                
                Text(":")
                
                Picker("minute", selection: $gov.ac.timerMinute) {
                    ForEach(0...99, id: \.self) { i in
                        Text(String(format: "%02d", i)).tag(i)
                            .font(.title).bold()
                    }
                }
                .frame(width: 80)
                
                Text(":")
                
                Picker("second", selection: $gov.ac.timerSecond) {
                    ForEach(0...99, id: \.self) { i in
                        Text(String(format: "%02d", i)).tag(i)
                            .font(.title).bold()
                    }
                }
                .frame(width: 80)
                
            }
            .monospacedDigit()
            .pickerStyle(.wheel)
            .frame(height: 100)
            
            HStack {
                Spacer()
                Text("gregorian:")
                Text(gov.ac.newTimer.gregDurationTxt)
                    .font(.title)
            }
            .foregroundStyle(.gray).bold()
            .padding(.bottom)
            
            HStack {
                Spacer()
                
                if gov.ac.activeTimers.count < 3 {
                    SmallTimeButtonView(
                        imageString: "timer",
                        text: gov.ac.newTimer.duration == 0 ? "set" : "start",
                        action: { startTimer(oldTimer: nil) },
                        color: gov.ac.newTimer.duration > 0 ? .metricOrange : .gray
                    )
                    .disabled(gov.ac.newTimer.duration == 0)
                } else {
                    SmallTimeButtonView(
                        imageString: "timer.circle.fill",
                        text: "timers full",
                        action: { return },
                        color: .gray
                    )
                    .disabled(true)
                }

            }
            
            Spacer()
        }
    }
    
    private func startTimer(oldTimer: MetrixtTimer?) {
        gov.ac.setTimer(oldTimer: oldTimer)
    }
}

#Preview {
    TimerView(gov: Governor())
}
