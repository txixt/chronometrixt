//
//  MetricDateSteppers.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/13/26.
//

import SwiftUI
import SwiftData

struct MetricDateSteppers: View {
    @Bindable var gov: Governor
    @Bindable var eg: EventComptroller
    var target: EventComptroller.EditingFields
    
    var body: some View {
        let isStart = target == .startDateMetric
        let time: MetrixtTime = isStart ? eg.metricStart : eg.metricEnd
        let isLeapYear = metric.cal.isLeapYear(time.year)
        let weekMax: Int = time.month == 3 ? 6 : 9
        let dayMax: Int = time.month == 3 && time.week == 6 ? isLeapYear ? 5 : 4 : 9
        
        HStack(spacing: 0) {
            MetricDateStepper(label: "year", value: time.year, range: 0...9999) { value in
                setTime(isStart: isStart, time: time, component: .year, value: value)
            }
            
            Text(".").font(.caption).offset(y: 8)
            
            MetricDateStepper(label: "month", value: time.month, range: 0...3) { value in
                setTime(isStart: isStart, time: time, component: .month, value: value)
            }
            Text(":").font(.caption).offset(y: 8)
            MetricDateStepper(label: "week", value: time.week, range: 0...weekMax) { value in
                setTime(isStart: isStart, time: time, component: .week, value: value)
            }
            Text(":").font(.caption).offset(y: 8)
            MetricDateStepper(label: "day", value: time.day, range: 0...dayMax) { value in
                setTime(isStart: isStart, time: time, component: .day, value: value)
            }
            
            Text(".").font(.caption).offset(y: 8)
            
            MetricDateStepper(label: "hour", value: time.hour, range: 0...9) { value in
                setTime(isStart: isStart, time: time, component: .hour, value: value)
            }
            Text(":").font(.caption).offset(y: 8)
            MetricDateStepper(label: "min", value: time.minute, range: 0...99) { value in
                setTime(isStart: isStart, time: time, component: .minute, value: value)
            }
        }
        .padding(.bottom)
    }
    
    private func setTime(isStart: Bool, time: MetrixtTime, component: MetrixtCalendar.Component, value: Int) {
        if isStart {
            eg.metricStart = metric.cal.replace(time: time, component: .minute, with: value)
            eg.gregStart = eg.metricStart.toGreg()
        } else {
            eg.metricEnd = metric.cal.replace(time: time, component: .minute, with: value)
            eg.gregEnd = eg.metricEnd.toGreg()
        }
        eg.enforceEntropy()
    }
}
struct MetricDateStepper: View {
    var label: String
    var value: Int
    var range: ClosedRange<Int>
    var onChange: (Int) -> Void
    
    var body: some View {
        VStack {
            Text(label)
                .font(.system(size: 8))
            Picker(label, selection: Binding(
                get: { min(value, range.upperBound) },
                set: { onChange($0) }
            )) {
                ForEach(range, id: \.self) { i in
                    HStack {
                        Spacer()
                        Text(String(i)).tag(i)
                            .font(.callout)
                            .bold()
                        Spacer()
                    }
                }
            }
            .pickerStyle(.wheel)
            .frame(width: label == "year" ? 100 : label == "min" ? 60 : 44, height: 90)
            .clipped()
        }
    }
}


#Preview {
    @Previewable @Environment(\.modelContext) var context
    let gov = Governor(context: context)
    let eg = PreviewEG().eg()
    MetricDateSteppers(
        gov: gov,
        eg: eg,
        target: .startDateMetric
    )
}
