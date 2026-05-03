//
//  EventEndDateGregEditorView.swift
//  chronometrixt
//
//  Created by Becket on 3/20/26.
//

import SwiftUI

struct EventEndDateGregEditorView: View {
    @Bindable var gov: Governor
    @Bindable var eg: EventComptroller
    
    var body: some View {
        MetrixtSubdivider()
        
        VStack {
            HStack {
                Text("set duration:")
                    .font(.caption)
                Spacer()
            }
            .padding(.bottom)
            
            HStack {
                AddGregTimeButton(text: "all day", value: 0, action: { basta(0) })
                AddGregTimeButton(text: "1m", value: 1, action: { basta(1) })
                AddGregTimeButton(text: "5m", value: 5, action: { basta(5) })
                AddGregTimeButton(text: "10m", value: 10, action: { basta(10) })
                AddGregTimeButton(text: "15m", value: 15, action: { basta(15) })
            }
            HStack {
                AddGregTimeButton(text: "30m", value: 30, action: { basta(30) })
                AddGregTimeButton(text: "45m", value: 45, action: { basta(45) })
                AddGregTimeButton(text: "1h", value: 60, action: { basta(60) })
                AddGregTimeButton(text: "2h", value: 120, action: { basta(120) })
                AddGregTimeButton(text: "3h", value: 180, action: { basta(180) })
            }
            .padding(.bottom)
                
            HStack{
                Text("end time:")
                    .font(.caption)
                Spacer()
            }
            
            DatePicker("", selection: $eg.gregEnd, displayedComponents: [.date, .hourAndMinute]).monospacedDigit()
                .datePickerStyle(.compact)
                .tint(.primary)
                .foregroundColor(.primary)
                .labelsHidden()
                .padding(.bottom)
                .onChange(of: eg.gregEnd) {
                    eg.metricEnd = MetrixtTime(date: eg.gregEnd)
                    eg.enforceEntropy()
                }
                .padding(.bottom)
            
            HStack {

                SubmitButtonView(imageString: "checkmark", text: "ended", action: { eg.editField = .none })
            }
            
            MetrixtSubdivider()
        }
        .monospaced()
            
    }
    
    private func basta(_ value: Int) {
        if value == 0 { eg.allDayToggle(); return }
        eg.gregEnd = eg.gregStart.addingTimeInterval(TimeInterval(value * 60))
        eg.metricEnd = MetrixtTime(date: eg.gregEnd)
        eg.enforceEntropy()
    }
    
    private func reset() {
        eg.gregEnd = eg.gregStart.addingTimeInterval(TimeInterval(1))
        eg.metricEnd = MetrixtTime(date: eg.gregEnd)
    }
}

struct AddGregTimeButton: View {
    var text: String
    var value: Int
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.caption2)
                .foregroundColor(.primary)
                .frame(width: 60, height: 30)
                .background(RoundedRectangle(cornerRadius: 10).fill(.gray).opacity(text == "all day" ? 0.2 : 0.3))
        }
    }
}

#Preview {
    let gov = Governor()
    let eg = PreviewEG().eg()
    EventEndDateGregEditorView(gov: gov, eg: eg)
}
