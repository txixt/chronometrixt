//
//  AlarmView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/15/26.
//

import SwiftUI
import SwiftData

struct AlarmView: View {
    @Query var alarmData: [MetricAlarm]
    @Environment(\.modelContext) private var context
    @Bindable var gov: Governor
    @Bindable var ag: AlarmGovernor
    private enum Component { case hour, minute, second }
    
    var body: some View {
        VStack {
            Spacer()
            
            if !ag.activeAlarms.isEmpty {
                ForEach(ag.activeAlarms, id: \.id) { alarm in
                    ZStack {
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(alarm.deadline.hourMinuteSecondTxt)
                                    .font(.title2).bold()
                                Text(alarm.deadline.toGreg().formatted(date: .omitted, time: .standard))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: { ag.dismissAlarm(alarm: alarm) }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.primary).bold()
                                    .shadow(radius: 3)
                            }
                            
                            Text(alarm.countdownTxt)
                                .font(.title2).bold()
                                .frame(width: 100, height: 33)
                                .foregroundStyle(.primary)
                                .background(RoundedRectangle(cornerRadius: 10).fill(.gray).opacity(0.2))
                                .shadow(radius: 5)
                        }
                    }
                }
            }
            
            if !ag.alarms.isEmpty {
                ForEach(ag.alarms, id: \.id) { alarm in
                    ZStack {
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(alarm.hourMinuteSecondTxt)
                                    .font(.title2).bold()
                                Text(alarm.toGreg().formatted(date: .omitted, time: .standard))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: { setAlarm(oldAlarm: alarm) }) {
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
            
            if let na = ag.newAlarm {
                
                HStack(spacing: 0) {
                    Spacer()
                    
                    Text("new alarm:").bold()
                        .padding(.trailing)
                    
                    Picker("hour", selection: $ag.alarmHour) {
                        ForEach(0...9, id: \.self) { i in
                            Text(String(i)).tag(i)
                                .font(.title).bold()
                        }
                    }
                    .frame(width: 60)

                    Text(":").padding(.top)
                    
                    Picker("minute", selection: $ag.alarmMinute) {
                        ForEach(0...99, id: \.self) { i in
                            Text(String(format: "%02d", i)).tag(i)
                                .font(.title).bold()
                        }
                    }
                    .frame(width: 80)

                    Text(":")
                    
                    Picker("second", selection: $ag.alarmSecond) {
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
        
                    Text("gregorian time:")
                    
                    Text(na.toGreg().formatted(date: .omitted, time: .standard))
                        .font(.title)
                }
                .foregroundStyle(.gray).bold()
                .padding(.bottom)
            }

            HStack {
                Spacer()
                
                if ag.activeAlarms.count < 3 {
                    SmallTimeButtonView(imageString: "bell", text: "set", action: { setAlarm(oldAlarm: nil) }, color: .metricOrange)
                } else {
                    SmallTimeButtonView(imageString: "bell.slash", text: "alarms full", action: { return }, color: .gray)
                        .disabled(true)
                }
            }
            
            Spacer()
            
        }
    }
    
    private func setAlarm(oldAlarm: MetrixtTime?) {
        ag.setAlarm(data: alarmData, context: context, eternalNow: gov.eternalNow.time, oldAlarm: oldAlarm)
    }
}

#Preview {
    AlarmView(gov: Governor(), ag: AlarmGovernor())
}
