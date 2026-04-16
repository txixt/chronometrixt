//
//  SmallTimesView.swift
//  chronometrixt
//
//  Created by Becket on 4/14/26.
//

import SwiftUI

struct SmallTimesView: View {
    @Bindable var gov: Governor
    @State var ag: AlarmGovernor = AlarmGovernor()
    
    var body: some View {
        SheetHeaderView(
            gov: gov,
            title: ag.mode == .alarm ? "alarm" : ag.mode == .timer ? "timer" : "stopwatch",
            titleImage: "timelapse"
        )
        
        Spacer()
        
        TabView(selection: $ag.mode) {
            TimerView()
                .tag(AlarmGovernor.SmallTimeMode.timer)
            
            AlarmView()
                .tag(AlarmGovernor.SmallTimeMode.alarm)

            StopwatchView(gov: gov, ag: ag)
                .tag(AlarmGovernor.SmallTimeMode.stopwatch)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        
        Spacer()
        
        MetrixtSubdivider()
        
        HStack {
            Image(systemName: ag.mode != .timer ? "timer.circle" : "timer.circle.fill")
            Image(systemName: ag.mode != .alarm ? "alarm" : "alarm.fill")
            Image(systemName: ag.mode != .stopwatch ? "stopwatch" : "stopwatch.fill")
        }
        
        Spacer()
    }
}

#Preview {
    SmallTimesView(gov: Governor())
}
