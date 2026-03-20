//
//  EventAlarmEditorView.swift
//  chronometrixt
//
//  Created by Becket on 3/20/26.
//

import SwiftUI

struct EventAlarmEditorView: View {
    @Bindable var eg: EventGovernor
    @State var alarm: EventAlarm = EventAlarm(id: UUID().uuidString, offset: 0, type: .notification)
    
    private let offsets: [(String, TimeInterval)] = [
        ("none", 0),
        ("at time of event", 1),
        ("5 min before", 5 * 60),
        ("10 min before", 10 * 60),
        ("30 min before", 30 * 60),
        ("1 hour before", 60 * 60),
        ("1 day before", 86400),
    ]
    
    var body: some View {
        VStack {
            MetrixtSubdivider()
            
            HStack {
                Text("alarms: ")
                    .font(.caption)
                Spacer()
            }
            .padding(.bottom)
            
            HStack(alignment: .top) {
                if !eg.alarms.isEmpty {
                    Spacer()
                    VStack {
                        let text = offsets.first(where: { $0.1 == eg.alarms.first!.offset })?.0 ?? "none"
                        Image(systemName: "bell")
                            .rotationEffect(Angle(degrees: 10))
                            .padding(.bottom)
                        Text(text)
                            .font(.footnote)
                            .padding(.bottom)
                        Button(action: { eg.alarms.removeFirst() }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                        }
                    }
                    .bold()
                }
                if eg.alarms.isEmpty || eg.alarms.count == 1 {
                    Spacer()
                    VStack {
                        if eg.alarms.count == 1 {
                            Text("second alarm?")
                                .font(.caption)
                        }
                        Picker("alarm", selection: $alarm.offset) {
                            ForEach(offsets, id: \.0) { name, value in
                                Text(name).tag(value)
                            }
                        }
                        .labelsHidden()
                        .tint(.primary)
                        .onChange(of: alarm.offset) { _, value in
                            if value == 0 { return }
                            eg.alarms.append(alarm)
                            alarm.offset = 0
                        }
                    }
                    .frame(height: 110)
                    Spacer()
                }
                if eg.alarms.count == 2 {
                    Spacer()
                    VStack {
                        let text = offsets.first(where: { $0.1 == eg.alarms[1].offset })?.0 ?? "none"
                        Image(systemName: "bell")
                            .rotationEffect(Angle(degrees: -10))
                            .padding(.bottom)
                        Text(text)
                            .font(.footnote)
                            .padding(.bottom)
                        Button(action: { eg.alarms.removeFirst() }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                        }
                    }
                    .bold()
                    Spacer()
                }
                
            }
            .foregroundColor(.primary)
            .padding(.bottom)
            .monospaced()
         
            SubmitButtonView(imageString: "checkmark", text: "adjusted",action: {eg.editField = .none})
            
            MetrixtSubdivider()
        }
    }
}

#Preview {
    EventAlarmEditorView(
        eg: EventGovernor(
            title: "sample",
            starting: MetrixtTime(years: 5056, seconds: 123456),
            ending: MetrixtTime(years: 5056, seconds: 123459))
    )
}
