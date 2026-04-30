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
    @Bindable var ag: AlarmGovernor
    
    var body: some View {
        VStack {
            Spacer()
            if !ag.activeTimers.isEmpty {
                ForEach(ag.activeTimers, id: \.id) { timer in
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
                            
                            Button(action: { ag.cancelTimer(timer: timer )}) {
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
            
            if !ag.timers.isEmpty {
                ForEach(ag.timers, id: \.id) { timer in
                    ZStack {
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(timer.durationTxt)
                                    .font(.title2).bold()
                                Text(timer.gregDurationTxt)
                            }
                            
                            Spacer()
                            
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
            
            if !ag.activeTimers.isEmpty || !ag.timers.isEmpty {
                MetrixtSubdivider()
            }
            
            HStack(spacing: 0) {
                Spacer()
                
                Text("new timer:").bold()
                
                Picker("hour", selection: $ag.timerHour) {
                    ForEach(0...9, id: \.self) { i in
                        Text(String(i)).tag(i)
                            .font(.title).bold()
                    }
                }
                .frame(width: 60)
                
                Text(":")
                
                Picker("minute", selection: $ag.timerMinute) {
                    ForEach(0...99, id: \.self) { i in
                        Text(String(format: "%02d", i)).tag(i)
                            .font(.title).bold()
                    }
                }
                .frame(width: 80)
                
                Text(":")
                
                Picker("second", selection: $ag.timerSecond) {
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
                Text(ag.newTimer.gregDurationTxt)
                    .font(.title)
            }
            .foregroundStyle(.gray).bold()
            .padding(.bottom)
            
            HStack {
                Spacer()
                
                if ag.activeTimers.count < 3 {
                    SmallTimeButtonView(
                        imageString: "timer",
                        text: ag.newTimer.duration == 0 ? "set" : "start",
                        action: { startTimer(oldTimer: nil) },
                        color: ag.newTimer.duration > 0 ? .metricOrange : .gray
                    )
                    .disabled(ag.newTimer.duration == 0)
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
        ag.setTimer(data: timerData, context: context, eternalNow: gov.eternalNow.time, oldTimer: oldTimer)
    }
}

#Preview {
    TimerView(gov: Governor(), ag: AlarmGovernor())
}
