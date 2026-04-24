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
                ForEach(ag.activeTimers, id: \.deadline.id) { timer in
                    ZStack {
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(timer.deadline.hourMinuteSecondTxt)
                                    .font(.title2).bold()
                                Text(timer.deadline.toGreg().formatted(date: .omitted, time: .shortened))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.primary).bold()
                            }
                            
                            Text(timer.countdown.hourMinuteSecondTxt)
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
                                Text(timer.hourMinuteSecondTxt)
                                    .font(.title2).bold()
                                Text(timer.toGreg().formatted(date: .omitted, time: .shortened))
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
            
            MetrixtSubdivider()
            
            if let nt = ag.newTimer {
                
                HStack(spacing: 0) {
                    Text("new timer: ").bold()
                        .padding(.trailing)
                    
                    Picker("hour", selection: $ag.timerHour) {
                        ForEach(0...9, id: \.self) { i in
                            Text(String(i)).tag(i)
                                .font(.title).bold()
                        }
                    }
                    
                    Text(":")
                    
                    Picker("minute", selection: $ag.timerMinute) {
                        ForEach(0...99, id: \.self) { i in
                            Text(String(format: "%02d", i)).tag(i)
                                .font(.title).bold()
                        }
                    }
                    
                    Text(":")
                    
                    Picker("second", selection: $ag.timerSecond) {
                        ForEach(0...99, id: \.self) { i in
                            Text(String(format: "%02d", i)).tag(i)
                                .font(.title).bold()
                        }
                    }
                }
                .monospacedDigit()
                .pickerStyle(.wheel)
                .frame(height: 100)
                
                HStack {
                    Spacer()
                    Text("gregorian: ")
                    Text(nt.toGreg().formatted(date: .omitted, time: .shortened))
                        .font(.title)
                }
                .foregroundStyle(.gray).bold()
                .padding(.bottom)
            }
            
            HStack {
                Spacer()
                
                SmallTimeButtonView(
                    imageString: "timer",
                    text: "start",
                    action: { startTimer(oldTimer: nil) },
                    color: .metricOrange
                )
            }
            
            Spacer()
        }
    }
    
    private func startTimer(oldTimer: MetrixtTime?) {
        ag.setTimer(data: timerData, context: context, eternalNow: gov.eternalNow.time, oldTimer: oldTimer)
    }
}

#Preview {
    TimerView(gov: Governor(), ag: AlarmGovernor())
}
