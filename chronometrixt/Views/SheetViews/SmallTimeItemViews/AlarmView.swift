//
//  AlarmView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/15/26.
//

import SwiftUI
import SwiftData

struct AlarmView: View {
    @Bindable var gov: Governor
    @Bindable var ag: AlarmGovernor
    private enum Component { case hour, minute, second }
    
    var body: some View {
        VStack {
            Spacer()
            
            if !ag.activeAlarms.isEmpty {
                ForEach(ag.activeAlarms, id: \.deadline.id) { alarm in
                    ZStack {
                        Divider()
                        
                        HStack {
                            Text(alarm.deadline.hourMinuteSecondTxt)
                            
                            Spacer()
                            
                            Text("\(alarm.currentTime.seconds - alarm.deadline.seconds)")
                                .foregroundStyle(.background)
                                .background(RoundedRectangle(cornerRadius: 10).fill(.gray))
                                .frame(width: 110, height: 55)
                        }
                    }
                }
            }
            
            if !ag.alarms.isEmpty {
                ForEach(ag.alarms) { alarm in
                    ZStack {
                        Divider()
                        
                        HStack {
                            Text(alarm.hourMinuteSecondTxt)
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image(systemName: "arrow.3.trianglepath")
                                    .foregroundStyle(.background)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(.metricOrange))
                                    .frame(width: 110, height: 55)
                            }
                        }
                    }
                }
            }
            
            if let na = ag.newAlarm {
                HStack {
                    Text("new alarm:")
                    Spacer()
                }
                
                HStack(spacing: 0) {
                    Text(na.yearTxt + "." + na.mwdTxt + ".")
                        .padding(.trailing)
                    
                    Picker("hour", selection: $ag.newAlarm) {
                        ForEach(0...9, id: \.self) { i in
                            Text(String(na.hour)).tag(na.hour)
                                .font(.title).bold()
                        }
                    }
                    .frame(width: 60)

                    Text(":").padding(.top)
                    
                    Picker("minute", selection: $ag.alarmSeconds) {
                        ForEach(0...99, id: \.self) { i in
                            Text(String(format: "%02d", i)).tag(i)
                                .font(.title).bold()
                        }
                    }
                    .frame(width: 80)

                    Text(":")
                    
                    Picker("minute", selection: $ag.alarmSeconds) {
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
                .padding(.bottom)

                Text(na.toGreg().formatted())
                    .font(.title)
                    .foregroundStyle(.gray)
            }
            
            
            Spacer()
            
            HStack {
                Spacer()
                
                SmallTimeButtonView(imageString: "bell", text: "set", action: setAlarm, color: .metricOrange)
            }
            
            Spacer()
            
        }
        .onAppear { ag.newAlarm = MetrixtTime(date: nil) }
        .padding()
        .monospaced()
    }
    
    private func setAlarm() {
        
    }
}

#Preview {
    AlarmView(gov: Governor(), ag: AlarmGovernor())
}
