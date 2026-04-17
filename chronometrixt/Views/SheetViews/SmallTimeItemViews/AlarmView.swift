//
//  AlarmView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/15/26.
//

import SwiftUI

struct AlarmView: View {
    @Bindable var gov: Governor
    @Bindable var ag: AlarmGovernor
    private enum Component { case hour, minute, second }
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                VStack {
                    Text("hour").font(.caption)
                    Picker("hour", selection: $ag.alarmSeconds) {
                        ForEach(0...9, id: \.self) { i in
                            Text(String(i)).tag(i)
                                .font(.largeTitle).bold()
                        }
                    }
                    .frame(width: 80)
                }

                Text(":").padding(.top)
                
                VStack {
                    Text("minute").font(.caption)
                    Picker("minute", selection: $ag.alarmSeconds) {
                        ForEach(0...99, id: \.self) { i in
                            Text(String(format: "%02d", i)).tag(i)
                                .font(.largeTitle).bold()
                        }
                    }
                    .frame(width: 100)
                }

                Text(":").padding(.top)
                
                VStack {
                    Text("second").font(.caption)
                    Picker("minute", selection: $ag.alarmSeconds) {
                        ForEach(0...99, id: \.self) { i in
                            Text(String(format: "%02d", i)).tag(i)
                                .font(.largeTitle).bold()
                        }
                    }
                    .frame(width: 100)
                }

            }
            .monospacedDigit()
            .pickerStyle(.wheel)
            .frame(height: 100)
            .padding(.bottom)
            
            HStack {
                Text("gregorian: 9:45 am")
                    .font(.title2)
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                SmallTimeButtonView(imageString: "bell", text: "set", action: setAlarm, color: .metricOrange)
            }
            
            Spacer()
            
        }
        .padding()
        .monospaced()
    }
    
    private func setAlarm() {
        
    }
}

#Preview {
    AlarmView(gov: Governor(), ag: AlarmGovernor())
}
