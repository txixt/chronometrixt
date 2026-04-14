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
        SheetHeaderView(gov: gov, title: "small times", titleImage: "timelapse")
        
        Spacer()
        
        TabView {
            
            
        }
        
        Spacer()
        
        MetrixtSubdivider()
        
        HStack {
            Image(systemName: ag.mode == .timer ? "timer.circle" : "timer.circle.fill")
            Image(systemName: ag.mode == .alarm ? "alarm" : "alarm.fill")
            Image(systemName: ag.mode == .stopwatch ? "stopwatch" : "stopwatch.fill")
        }
        
        Spacer()
    }
}

#Preview {
    SmallTimesView(gov: Governor())
}
