//
//  SmallTimesView.swift
//  chronometrixt
//
//  Created by Becket on 4/14/26.
//

import SwiftUI
import SwiftData

struct SmallTimesView: View {
    @Query var alarms: [MetricAlarm]
    @Bindable var gov: Governor
    @State var ag: AlarmGovernor = AlarmGovernor()
    
    var body: some View {
        VStack {
            
            SheetHeaderView(
                gov: gov,
                title: ag.mode == .alarm ? "alarm" : ag.mode == .timer ? "timer" : "stopwatch",
                titleImage: "timelapse"
            )
            
            Spacer()
            
            TabView(selection: $ag.mode) {
                TimerView(gov: gov, ag: ag)
                    .tag(AlarmGovernor.SmallTimeMode.timer)
                
                AlarmView(gov: gov, ag: ag)
                    .tag(AlarmGovernor.SmallTimeMode.alarm)

                StopwatchView(gov: gov, ag: ag)
                    .tag(AlarmGovernor.SmallTimeMode.stopwatch)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            Spacer()
            
            MetrixtSubdivider()
            
            HStack {
                Button(action: { ag.mode = .timer }) {
                    Image(systemName: ag.mode != .timer ? "timer.circle" : "timer.circle.fill")
                        .shadow(radius: ag.mode == .timer ? 0 : 5)
                }
                Button(action: { ag.mode = .alarm }) {
                    Image(systemName: ag.mode != .alarm ? "alarm" : "alarm.fill")
                        .shadow(radius: ag.mode == .alarm ? 0 : 5)
                }
                Button(action: { ag.mode = .stopwatch }) {
                    Image(systemName: ag.mode != .stopwatch ? "stopwatch" : "stopwatch.fill")
                        .shadow(radius: ag.mode == .stopwatch ? 0 : 5)
                }
            }
            .tint(.primary)
            
            Spacer()
        }
        .monospaced()
        .padding()
        .onAppear() { ag.populate(data: alarms, eternalNow: gov.eternalNow.time) }
    }
}

#Preview {
    SmallTimesView(gov: Governor())
}
