//
//  MetricDateEditorView.swift
//  chronometrixt
//
//  Created by Becket on 3/19/26.
//

import SwiftUI

struct MetricDateEditorView: View {
    @Bindable var gov: Governor
    @Bindable var eg: EventGovernor
    var target: EventGovernor.EditingFields
    
    var body: some View {
        let isStart = target == .startDateMetric
        let time: MetrixtTime = isStart ? eg.metricStart : eg.metricEnd
        let isLeapYear = metric.cal.isLeapYear(time.year)
        let weekMax: Int = time.month == 3 ? 6 : 9
        let dayMax: Int = time.month == 3 && time.week == 6 ? isLeapYear ? 5 : 4 : 9
        
        VStack {
            MetrixtSubdivider()
            
            HStack {
                Text(isStart ? "adjust metric end time:" : "adjust metric end time:")
                    .font(.caption)
                Spacer()
            }
            .padding(.bottom)
            
            HStack(spacing: 0) {
                MetricDateStepper(label: "year", value: time.year, range: 0...9999) { value in
                    if isStart {
                        eg.metricStart = metric.cal.replace(time: time, component: .year, with: value)
                    } else {
                        eg.metricEnd = metric.cal.replace(time: time, component: .year, with: value)
                        dateLimiter()
                    }
                }
                
                Text(".").font(.caption).offset(y: 8)
                
                MetricDateStepper(label: "month", value: time.month, range: 0...3) { value in
                    if isStart {
                        eg.metricStart = metric.cal.replace(time: time, component: .month, with: value)
                    } else {
                        eg.metricEnd = metric.cal.replace(time: time, component: .month, with: value)
                        dateLimiter()
                    }
                }
                Text(":").font(.caption).offset(y: 8)
                MetricDateStepper(label: "week", value: time.week, range: 0...weekMax) { value in
                    if isStart {
                        eg.metricStart = metric.cal.replace(time: time, component: .week, with: value)
                    } else {
                        eg.metricEnd = metric.cal.replace(time: time, component: .week, with: value)
                        dateLimiter()
                    }
                }
                Text(":").font(.caption).offset(y: 8)
                MetricDateStepper(label: "day", value: time.day, range: 0...dayMax) { value in
                    if isStart {
                        eg.metricStart = metric.cal.replace(time: time, component: .day, with: value)
                    } else {
                        eg.metricEnd = metric.cal.replace(time: time, component: .day, with: value)
                        dateLimiter()
                    }
                }
                
                Text(".").font(.caption).offset(y: 8)
                
                MetricDateStepper(label: "hour", value: time.hour, range: 0...9) { value in
                    if isStart {
                        eg.metricStart = metric.cal.replace(time: time, component: .hour, with: value)
                    } else {
                        eg.metricEnd = metric.cal.replace(time: time, component: .hour, with: value)
                        dateLimiter()
                    }
                }
                Text(":").font(.caption).offset(y: 8)
                MetricDateStepper(label: "min", value: time.minute, range: 0...99) { value in
                    if isStart {
                        eg.metricStart = metric.cal.replace(time: time, component: .minute, with: value)
                    } else {
                        eg.metricEnd = metric.cal.replace(time: time, component: .minute, with: value)
                        dateLimiter()
                    }
                }
            }
            .padding(.bottom)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("gregorian equivalent: ")
                        .font(.caption)
                    Text(isStart ? eg.metricStart.toGreg().formatted() : eg.metricEnd.toGreg().formatted())
                        .bold()
                }
                Spacer()
            }
            .padding(.bottom)
            
            Button(action: { eg.editField = .none }) {
                HStack {
                    Image(systemName: "checkmark")
                    Text("adjusted")
                }
                .font(.caption2)
                .bold()
                .foregroundColor(.primary)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.gray).opacity(0.5))
                .shadow(radius: 3)
            }
            
            
            MetrixtSubdivider()
        }
        .monospaced()
    }
    
    private func dateLimiter() {
        if eg.metricStart.years >= eg.metricEnd.year && eg.metricStart.seconds >= eg.metricEnd.second {
            eg.metricEnd = metric.cal.replace(time: eg.metricStart, component: .second, with: eg.metricStart.second + 1)
            gov.errorMessage = "end date must be after start date"
            gov.alert = .error
        }
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
                            .font(.caption)
                            .bold()
                        Spacer()
                    }
                }
            }
            .pickerStyle(.wheel)
            .frame(width: label == "year" ? 70 : label == "min" ? 50 : 44, height: 90)
            .clipped()
        }
    }
}

#Preview {
    MetricDateEditorView(
        gov: Governor(),
        eg: EventGovernor(
            title: "sample",
            starting: MetrixtTime(years: 5056, seconds: 12345678),
            ending: MetrixtTime(years: 5056, seconds: 1234579)
        ),
        target: .startDateMetric
    )
}
