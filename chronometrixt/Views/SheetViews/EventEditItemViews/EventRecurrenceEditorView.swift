//
//  EventRecurrenceEditorView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/21/26.
//

import SwiftUI

struct EventRecurrenceEditorView: View {
    @Bindable var eg: EventComptroller
    @State var limit: Limiters = .none
    enum Limiters { case none, metric, gregorian, iterations }
    let chronologyError: ()-> Void
    private let recursives: [(String, RecurrenceRule.Frequency)] = [
        ("none", .none),
        ("daily", .daily),
        ("gregorian weekly", .weekly),
        ("metric weekly", .metricWeekly),
        ("gregorian monthly", .monthly),
        ("metric monthly", .metricMonthly),
        ("yearly", .yearly)
    ]
    
    var body: some View {
        VStack {
            MetrixtSubdivider()
            
            HStack {
                Text("recurrence: ")
                    .font(.caption)
                Spacer()
            }
            .padding(.bottom)
            
            Spacer()
            
            Picker("recurrence", selection: $eg.recurrence.frequency) {
                ForEach(recursives, id: \.0) { name, rule in
                    Text(name).tag(rule)
                }
            }
            .font(.body.monospacedDigit())
            .labelsHidden()
            .tint(.primary)
            .padding(.bottom)
            
            .onChange(of: eg.recurrence.frequency) {
                eg.recurrence.count = nil
                eg.recurrence.until = nil
            }
            
            Spacer()
            
            if eg.recurrence.frequency != .none {
                switch limit {
                case .none: LimitPickerView(eg: eg, limit: $limit)
                case .iterations: IterationPickerView(eg: eg, limit: $limit)
                case .metric: MetricPickerView(eg: eg, limit: $limit, chronologyError: chronologyError)
                case .gregorian: GregPickerView(eg: eg, limit: $limit, chronologyError: chronologyError)
                }
                Spacer()
            }

            SubmitButtonView(imageString: "checkmark", text: "iterated", action: { eg.editField = .none })
                .padding(.top)
            
            MetrixtSubdivider()
        }
        .frame(maxHeight: 450)
        .monospaced()
    }
}

struct LimitPickerView: View {
    @Bindable var eg: EventComptroller
    @Binding var limit: EventRecurrenceEditorView.Limiters
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("number of iterations: ")
                .font(.caption)
            RecurrenceOptionView(limit: $limit,
                                 value: eg.recurrence.count == nil ? "∞" : "\(eg.recurrence.count!)",
                                 imageString: "slider.horizontal.3",
                                 size: 2,
                                 target: .iterations
            )
            Text("repetition end date (metric): ")
                .font(.caption)
            RecurrenceOptionView(limit: $limit, value: eg.recurrence.until == nil ? "∞" : MetrixtTime(date: eg.recurrence.until!).fullDateTxt, imageString: "wrench", size: 2, target: .metric)
            Text("repetition end date (gregorian): ")
                .font(.caption)
            RecurrenceOptionView(limit: $limit, value: eg.recurrence.until == nil ? "∞" : eg.recurrence.until!.formatted(), imageString: "wrench", size: 2, target: .gregorian)
        }
    }
}
struct RecurrenceOptionView: View {
    @Binding var limit: EventRecurrenceEditorView.Limiters
    var label: String?
    var value: String
    var imageString: String
    var size: Int
    var titleColor: Color? = nil
    var labelColor: Color? = nil
    var target: EventRecurrenceEditorView.Limiters
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if label != nil {
                Text(label!)
                    .font(.caption2)
            }
            ZStack {
                Divider()
                HStack {
                    Text(value)
                        .font(size == 1 ? .title : size == 2 ? .title2 : size == 3 ? .title3 : .default)
                        .foregroundStyle(labelColor != nil ? labelColor! : titleColor ?? .primary)
                        .bold()
                    Spacer()
                    Button(action: { limit = target }) {
                        Image(systemName: imageString)
                    }
                    .shadow(color: .gray, radius: 3)
                }
            }
        }
        .foregroundColor(labelColor ?? .primary)
    }
}

struct IterationPickerView: View {
    @Bindable var eg: EventComptroller
    @Binding var limit: EventRecurrenceEditorView.Limiters
    
    var body: some View {
        HStack {
            Text("number of iterations: ")
                .font(.caption)
            
            Picker("iterations", selection: $eg.recurrence.count) {
                ForEach(1...100, id: \.self) { iteration in
                    Text("\(iteration)").tag(iteration)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80, height: 120)
            .clipped()
            .tint(.primary)
            .onChange(of: eg.recurrence.count) {
                syncUntilFromCount()
                limit = .none
            }
        }
    }
    
    private func syncUntilFromCount() {
        guard let count = eg.recurrence.count, count > 0 else {
            eg.recurrence.until = nil
            return
        }
        eg.recurrence.until = RecurrenceRule.untilFromCount(
            startDate: eg.gregStart,
            count: count,
            frequency: eg.recurrence.frequency,
            interval: eg.recurrence.interval
        )
    }
}

struct MetricPickerView: View {
    @Bindable var eg: EventComptroller
    @Binding var limit: EventRecurrenceEditorView.Limiters
    @State var time: MetrixtTime = metric.cal.update(time: MetrixtTime(date: Date.now), component: .year, byAdding: 1)
    let chronologyError: ()-> Void
    
    var body: some View {
        let isLeapYear = metric.cal.isLeapYear(time.year)
        let weekMax: Int = time.month == 3 ? 6 : 9
        let dayMax: Int = time.month == 3 && time.week == 6 ? isLeapYear ? 5 : 4 : 9
        
        VStack {
            Text("end of iterations: ")
            
            HStack(spacing: 0) {
                MetricDateStepper(label: "year", value: time.year, range: 0...9999) { value in
                    time = metric.cal.replace(time: time, component: .year, with: value)
                    verifyAndRegister()
                }
                
                Text(".").font(.caption).offset(y: 8)
                
                MetricDateStepper(label: "month", value: time.month, range: 0...3) { value in
                    time = metric.cal.replace(time: time, component: .month, with: value)
                    verifyAndRegister()
                }
                Text(":").font(.caption).offset(y: 8)
                MetricDateStepper(label: "week", value: time.week, range: 0...weekMax) { value in
                    time = metric.cal.replace(time: time, component: .week, with: value)
                    verifyAndRegister()
                }
                Text(":").font(.caption).offset(y: 8)
                MetricDateStepper(label: "day", value: time.day, range: 0...dayMax) { value in
                    time = metric.cal.replace(time: time, component: .day, with: value)
                    verifyAndRegister()
                }
                
                Text(".").font(.caption).offset(y: 8)
                
                MetricDateStepper(label: "hour", value: time.hour, range: 0...9) { value in
                    time = metric.cal.replace(time: time, component: .hour, with: value)
                    verifyAndRegister()
                }
                Text(":").font(.caption).offset(y: 8)
                MetricDateStepper(label: "min", value: time.minute, range: 0...99) { value in
                    time = metric.cal.replace(time: time, component: .minute, with: value)
                    verifyAndRegister()
                }
            }
            .padding(.bottom)
            
            
            Button(action: { limit = .none }) {
                Image(systemName: "checkmark")
            }
            .tint(.primary)
            .shadow(color: .primary, radius: 3)
        }
        .onAppear() { if eg.recurrence.until != nil { time = MetrixtTime(date: eg.recurrence.until!) } }
    }
    
    private func verifyAndRegister() {
        let greg = time.toGreg()
        if greg < Date.now {
            time = metric.cal.update(time: MetrixtTime(date: Date.now), component: .year, byAdding: 1)
            chronologyError()
            print("chronology error")
        }
        eg.recurrence.until = greg
        eg.recurrence.count = RecurrenceRule.countFromUntil(
            startDate: eg.gregStart,
            untilDate: greg,
            frequency: eg.recurrence.frequency,
            interval: eg.recurrence.interval
        )
    }
}

struct GregPickerView: View {
    @Bindable var eg: EventComptroller
    @Binding var limit: EventRecurrenceEditorView.Limiters
    @State var date: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date.now) ?? Date.now
    let chronologyError: ()-> Void
    
    var body: some View {
        HStack {
            Text("end of iterations: ")
                .font(.caption)
                .offset(y: -8)
            DatePicker("", selection: $date, displayedComponents: [.date])
                .datePickerStyle(.compact)
                .tint(.primary)
                .foregroundColor(.primary)
                .labelsHidden()
                .padding(.bottom)
                .onChange(of: date) {
                    if date < Date.now {
                        eg.recurrence.until = date
                        chronologyError()
                    } else {
                        eg.recurrence.until = date
                        eg.recurrence.count = RecurrenceRule.countFromUntil(
                            startDate: eg.gregStart,
                            untilDate: date,
                            frequency: eg.recurrence.frequency,
                            interval: eg.recurrence.interval
                        )
                        limit = .none
                    }
                }
        }
        .onAppear() { if eg.recurrence.until != nil { date = eg.recurrence.until! } }
    }
}

#Preview {
    let gov = Governor()
    let eg = PreviewEG().eg()
    EventRecurrenceEditorView(
        eg: eg,
        chronologyError: EventEditMainView(
            gov: gov,
            update: false
        ).chronologyError
    )
}
