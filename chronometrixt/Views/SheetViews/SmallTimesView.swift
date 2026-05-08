//
//  SmallTimesView.swift
//  chronometrixt
//
//  Created by Becket on 4/14/26.
//

import SwiftUI
import SwiftData

struct SmallTimesView: View {
    @Environment(\.modelContext) private var context
    @Query var alarms: [MetricAlarm]
    @Bindable var gov: Governor
    
    var body: some View {
        VStack {
            
            SheetHeaderView(
                gov: gov,
                title: gov.ac.mode == .alarm ? "alarm" : gov.ac.mode == .timer ? "timer" : "stopwatch",
                titleImage: "timelapse"
            )
            
            Spacer()
            
            TabView(selection: $gov.ac.mode) {
                TimerView(gov: gov)
                    .tag(AlarmComptroller.SmallTimeMode.timer)
                
                AlarmView(gov: gov)
                    .tag(AlarmComptroller.SmallTimeMode.alarm)

                StopwatchView(gov: gov)
                    .tag(AlarmComptroller.SmallTimeMode.stopwatch)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            Spacer()
            
            MetrixtSubdivider()
            
            HStack {
                Button(action: { gov.ac.mode = .timer }) {
                    Image(systemName: gov.ac.mode != .timer ? "timer.circle" : "timer.circle.fill")
                        .shadow(radius: gov.ac.mode == .timer ? 0 : 5)
                }
                Button(action: { gov.ac.mode = .alarm }) {
                    Image(systemName: gov.ac.mode != .alarm ? "alarm" : "alarm.fill")
                        .shadow(radius: gov.ac.mode == .alarm ? 0 : 5)
                }
                Button(action: { gov.ac.mode = .stopwatch }) {
                    Image(systemName: gov.ac.mode != .stopwatch ? "stopwatch" : "stopwatch.fill")
                        .shadow(radius: gov.ac.mode == .stopwatch ? 0 : 5)
                }
            }
            .tint(.primary)
            
            Spacer()
            
            AlertView(gov: gov)
        }
        .monospaced()
        .padding()
        .onAppear() { prepAlarmComptroller() }
        .onDisappear() { gov.ac.stopwatch = nil }
    }
    
    private func prepAlarmComptroller() {
        gov.ac.populate(data: alarms)
    }
}

#Preview {
    SmallTimesView(gov: Governor())
}
