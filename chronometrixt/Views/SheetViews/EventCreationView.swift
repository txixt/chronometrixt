//
//  EventCreationView.swift
//  chronometrixt
//
//  Created by Becket on 3/17/26.
//

import SwiftUI

struct EventCreationView: View {
    @Environment(\.modelContext) private var context
    @Bindable var gov: Governor
    @State var eventGov: EventGovernor? = nil
    @State var eventTitle: String = ""
    @FocusState private var focus: FocusField?
    enum FocusField { case initialTitle, title, location, notes }
    
    var body: some View {
        
        VStack {
            SheetHeaderView(gov: gov, title: "new event", titleImage: "plus")
            
            ScrollView {
                VStack {
                    
                    if eventGov == nil {
                        EventCreationLandingView(
                            gov: gov,
                            eventTitle: $eventTitle,
                            focus: $focus,
                            onSubmit: finishEditingTitle)
                    }
                    
                    if eventGov != nil {
                        EventEditMainView(gov: gov, eventGov: eventGov!)
                    } else {
                        Spacer()
                    }
                    
                }
            }
        }
        .padding()
        .monospaced()
        
    }
    
    private func finishEditingTitle() {
        guard !eventTitle.isEmpty else { return }
        if eventGov == nil {
            initializeEvent()
        } else {
            eventGov!.title = eventTitle
        }
    }
    
    private func initializeEvent() {
        if gov.finiteNotNow == nil { gov.finiteNotNow = gov.eternalNow.time }
        eventGov = EventGovernor(
            title: eventTitle,
            starting: gov.finiteNotNow!,
            ending: metric.cal.update(time: gov.finiteNotNow!, component: .second, byAdding: 1)
        )
    }
//    
//    private func saveEvent() {
//        guard let eg = eventGov else { return }
//        let handler = EventHandler(modelContext: context)
//        eg.itsADate(handler: handler, gov: gov)
//    }
}

//struct EventLabelView: View {
//    @Binding var eventGov: EventGovernor
//    var label: String?
//    var value: String
//    var imageString: String
//    var size: Int
//    var titleColor: Color? = nil
//    var labelColor: Color? = nil
//    var target: EventGovernor.EditingFields
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            if label != nil {
//                Text(label!)
//                    .font(.caption2)
//            }
//            ZStack {
//                Divider()
//                HStack {
//                    Text(value)
//                        .font(size == 1 ? .title : size == 2 ? .title2 : size == 3 ? .title3 : .default)
//                        .foregroundStyle(labelColor != nil ? labelColor! : titleColor ?? .primary)
//                        .bold()
//                    Spacer()
//                    Button(action: { eventGov.editField = target }) {
//                        Image(systemName: imageString)
//                    }
//                    .shadow(color: .gray, radius: 3)
//                }
//            }
//        }
//        .foregroundColor(labelColor ?? .primary)
//    }
//}

// MARK: - Title Editor

struct TitleEditorView: View {
    @Bindable var eventGov: EventGovernor
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("title:")
                .font(.caption2)
            HStack {
                TextField("event title", text: Binding(
                    get: { eventGov.title },
                    set: { eventGov.title = String($0.prefix(42)) }
                ))
                .focused($isFocused)
                .onSubmit { isFocused = false; eventGov.editField = .none }
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 8).fill(.gray.opacity(0.2)))
                Button(action: { isFocused = false; eventGov.editField = .none }) {
                    Image(systemName: "checkmark")
                        .bold()
                }
            }
        }
        .padding(.bottom)
        .onAppear { isFocused = true }
    }
}

// MARK: - Metric Date Editor

struct MetricDateEditor: View {
    @Bindable var eg: EventGovernor
    var target: EventGovernor.EditingFields
    
    var body: some View {
        let isStart = (target == .startDateMetric)
        let time = isStart ? eg.metricStart : eg.metricEnd
        
        VStack(alignment: .leading, spacing: 4) {
            Text(isStart ? "metric start:" : "metric end:")
                .font(.caption2)
            
            HStack(spacing: 4) {
                // Year stepper
                MetricStepperCell(label: "Y", value: time.year, range: 0...99999) { v in
                    applyComponent(eg: eg, isStart: isStart, year: v)
                }
                Text(".").bold()
                // Month 0-3
                MetricStepperCell(label: "M", value: time.month, range: 0...3) { v in
                    applyComponent(eg: eg, isStart: isStart, month: v)
                }
                Text(":").bold()
                // Week 0-9 or 0-5
                MetricStepperCell(label: "W", value: time.week, range: 0...eg.maxWeek(forMonth: time.month)) { v in
                    applyComponent(eg: eg, isStart: isStart, week: v)
                }
                Text(":").bold()
                // Day
                MetricStepperCell(label: "D", value: time.day, range: 0...eg.maxDay(forMonth: time.month, week: time.week, year: time.year)) { v in
                    applyComponent(eg: eg, isStart: isStart, day: v)
                }
            }
            
            HStack(spacing: 4) {
                // Hour 0-9
                MetricStepperCell(label: "H", value: time.hour, range: 0...9) { v in
                    applyComponent(eg: eg, isStart: isStart, hour: v)
                }
                Text(":").bold()
                // Minute 0-99
                MetricStepperCell(label: "Mi", value: time.minute, range: 0...99) { v in
                    applyComponent(eg: eg, isStart: isStart, minute: v)
                }
                Text(":").bold()
                // Second 0-99
                MetricStepperCell(label: "Se", value: time.second, range: 0...99) { v in
                    applyComponent(eg: eg, isStart: isStart, second: v)
                }
                Spacer()
                Button(action: { eg.editField = .none }) {
                    Image(systemName: "checkmark").bold()
                }
            }
        }
        .padding(.bottom)
    }
    
    private func applyComponent(
        eg: EventGovernor, isStart: Bool,
        year: Int? = nil, month: Int? = nil, week: Int? = nil, day: Int? = nil,
        hour: Int? = nil, minute: Int? = nil, second: Int? = nil
    ) {
        let time = isStart ? eg.metricStart : eg.metricEnd
        let y = year ?? time.year
        let mo = month ?? time.month
        // Clamp week if month changed
        let maxW = eg.maxWeek(forMonth: mo)
        let w = min(week ?? time.week, maxW)
        // Clamp day if week/month changed
        let maxD = eg.maxDay(forMonth: mo, week: w, year: y)
        let d = min(day ?? time.day, maxD)
        let h = hour ?? time.hour
        let mi = minute ?? time.minute
        let se = second ?? time.second
        
        if isStart {
            eg.updateMetricStart(year: y, month: mo, week: w, day: d, hour: h, minute: mi, second: se)
        } else {
            eg.updateMetricEnd(year: y, month: mo, week: w, day: d, hour: h, minute: mi, second: se)
        }
    }
}

/// A small picker cell for a single metric component
struct MetricStepperCell: View {
    var label: String
    var value: Int
    var range: ClosedRange<Int>
    var onChange: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label).font(.system(size: 9)).foregroundStyle(.secondary)
            Picker(label, selection: Binding(
                get: { min(value, range.upperBound) },
                set: { onChange($0) }
            )) {
                ForEach(range, id: \.self) { i in
                    Text("\(i)").tag(i)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: label == "Y" ? 70 : 44, height: 80)
            .clipped()
        }
    }
}

// MARK: - Gregorian Date Editor

struct GregDateEditor: View {
    @Bindable var eventGov: EventGovernor
    var target: EventGovernor.EditingFields
    
    var body: some View {
        let isStart = (target == .startDateGreg)
        
        VStack(alignment: .leading, spacing: 4) {
            Text(isStart ? "gregorian start:" : "gregorian end:")
                .font(.caption2)
            HStack {
                DatePicker("", selection: isStart
                           ? Binding(get: { eventGov.gregStart }, set: { eventGov.gregStart = $0; eventGov.syncStartFromGreg() })
                           : Binding(get: { eventGov.gregEnd }, set: { eventGov.gregEnd = $0; eventGov.syncEndFromGreg() }),
                           displayedComponents: [.date, .hourAndMinute])
                .labelsHidden()
                Spacer()
                Button(action: { eventGov.editField = .none }) {
                    Image(systemName: "checkmark").bold()
                }
            }
        }
        .padding(.bottom)
    }
}

// MARK: - Alarm Editor

struct EventAlarmEditor: View {
    @Bindable var eg: EventGovernor
    
    private let offsets: [(String, TimeInterval)] = [
        ("none", 0),
        ("at time of event", 0),
        ("5 min before", 5 * 60),
        ("10 min before", 10 * 60),
        ("30 min before", 30 * 60),
        ("1 hour before", 60 * 60),
        ("1 day before", 86400),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("alarms:")
                .font(.caption2)
            Picker("alarm", selection: Binding(
                get: { eg.alarms.first?.offset ?? -1 },
                set: { newVal in
                    if newVal < 0 {
                        eg.alarms = []
                    } else {
                        eg.alarms = [EventAlarm(id: UUID().uuidString, offset: newVal, type: .notification)]
                    }
                }
            )) {
                Text("none").tag(TimeInterval(-1))
                ForEach(offsets.dropFirst(), id: \.1) { name, val in
                    Text(name).tag(val)
                }
            }
            .labelsHidden()
            
            HStack {
                Spacer()
                Button(action: { eg.editField = .none }) {
                    Image(systemName: "checkmark").bold()
                }
            }
        }
        .padding(.bottom)
    }
}

// MARK: - Recurrence Editor

struct EventRecurrenceEditor: View {
    @Bindable var eg: EventGovernor
    
    var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text("recurrence:")
                    .font(.caption2)
                Picker("frequency", selection: Binding(
                    get: { eg.recurrence.frequency },
                    set: { eg.recurrence.frequency = $0 }
                )) {
                    Text("none").tag(RecurrenceRule.Frequency.none)
                    Text("daily").tag(RecurrenceRule.Frequency.daily)
                    Text("weekly").tag(RecurrenceRule.Frequency.weekly)
                    Text("monthly").tag(RecurrenceRule.Frequency.monthly)
                    Text("yearly").tag(RecurrenceRule.Frequency.yearly)
                }
                .labelsHidden()
                
                if eg.recurrence.frequency != .none {
                    Stepper("every \(eg.recurrence.interval)", value: Binding(
                        get: { eg.recurrence.interval },
                        set: { eg.recurrence.interval = max(1, $0) }
                    ), in: 1...99)
                }
                
                HStack {
                    Spacer()
                    Button(action: { eg.editField = .none }) {
                        Image(systemName: "checkmark").bold()
                    }
                }
            }
            .padding(.bottom)
    }
}

// MARK: - Location Editor

struct EventLocationEditor: View {
    @Bindable var eg: EventGovernor
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
                Text("location:")
                    .font(.caption2)
                HStack {
                    TextField("location", text: Binding(
                        get: { eg.location },
                        set: { eg.location = $0 }
                    ))
                    .focused($isFocused)
                    .onSubmit { isFocused = false; eg.editField = .none }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 10).fill(.gray.opacity(0.2)))
                    Button(action: { isFocused = false; eg.editField = .none }) {
                        Image(systemName: "checkmark").bold()
                    }
                }
            }
            .padding(.bottom)
            .onAppear { isFocused = true }
    }
}

// MARK: - Notes Editor

struct EventNotesEditor: View {
    @Bindable var eg: EventGovernor
    @FocusState private var isFocused: Bool
    
    var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text("notes:")
                    .font(.caption2)
                TextEditor(text: Binding(
                    get: { eg.notes },
                    set: { eg.notes = $0 }
                ))
                .focused($isFocused)
                .frame(minHeight: 60, maxHeight: 120)
                .padding(4)
                .background(RoundedRectangle(cornerRadius: 8).stroke(.gray.opacity(0.3)))
                HStack {
                    Spacer()
                    Button(action: { isFocused = false; eg.editField = .none }) {
                        Image(systemName: "checkmark").bold()
                    }
                }
            }
            .padding(.bottom)
            .onAppear { isFocused = true }
    }
}

// MARK: - Calendar Editor (placeholder)

struct EventCalendarEditor: View {
    @Bindable var eg: EventGovernor
    
    var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text("calendar:")
                    .font(.caption2)
                HStack {
                    TextField("calendar", text: Binding(
                        get: { eg.calendar },
                        set: { eg.calendar = $0 }
                    ))
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(.gray.opacity(0.2)))
                    Button(action: { eg.editField = .none }) {
                        Image(systemName: "checkmark").bold()
                    }
                }
            }
            .padding(.bottom)
    }
}

// MARK: - Participant Editor (placeholder)

struct EventParticipantEditor: View {
    @Bindable var eg: EventGovernor
    
    var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text("participants:")
                    .font(.caption2)
                Text("\(eg.participants.count) participant(s)")
                    .foregroundStyle(.secondary)
                HStack {
                    Spacer()
                    Button(action: { eg.editField = .none }) {
                        Image(systemName: "checkmark").bold()
                    }
                }
            }
            .padding(.bottom)
    }
}

#Preview {
    EventCreationView(gov: Governor())
}


//                        if eventGov!.editField != .title {
//                            EventLabelView(eventGov: $eventGov,
//                                           label: nil,
//                                           value: eventGov!.title,
//                                           imageString: "square.and.pencil",
//                                           size: 1,
//                                           titleColor: .green,
//                                           target: .title)
//                            .padding(.bottom)
//                        } else {
//                            TitleEditorView(eventGov: $eventGov)
//                        }
//
//                        if eventGov!.editField != .startDateMetric {
//                            EventLabelView(eventGov: $eventGov,
//                                           label: "metric start: ",
//                                           value: eventGov!.metricStart.fullDateTxt,
//                                           imageString: "wrench",
//                                           size: 2,
//                                           target: .startDateMetric)
//                        } else {
//                            MetricDateEditor(eventGov: $eventGov, target: .startDateMetric)
//                        }
//
//                        if eventGov!.editField != .startDateGreg {
//                            EventLabelView(eventGov: $eventGov,
//                                           label: "gregorian start: ",
//                                           value: eventGov!.metricStart.toGreg().formatted(),
//                                           imageString: "wrench",
//                                           size: 2,
//                                           target: .startDateGreg)
//                            .padding(.bottom)
//                        } else {
//                            GregDateEditor(eventGov: $eventGov, target: .startDateGreg)
//                        }
//
//                        if eventGov!.editField != .endDateMetric {
//                            EventLabelView(eventGov: $eventGov,
//                                           label: "metric end: ",
//                                           value: eventGov!.metricEnd.fullDateTxt,
//                                           imageString: "wrench",
//                                           size: 2,
//                                           target: .endDateMetric)
//                        } else {
//                            MetricDateEditor(eventGov: $eventGov, target: .endDateMetric)
//                        }
//
//                        if eventGov!.editField != .endDateGreg {
//                            EventLabelView(eventGov: $eventGov,
//                                           label: "gregorian end: ",
//                                           value: eventGov!.metricEnd.toGreg().formatted(),
//                                           imageString: "wrench",
//                                           size: 2,
//                                           target: .endDateGreg)
//                            .padding(.bottom)
//                        } else {
//                            GregDateEditor(eventGov: $eventGov, target: .endDateGreg)
//                        }
//
//                        if eventGov!.editField != .alarms {
//                            EventLabelView(eventGov: $eventGov,
//                                           label: "alarms: ",
//                                           value: eventGov!.alarms.count.description,
//                                           imageString: "slider.horizontal.3",
//                                           size: 4,
//                                           target: .alarms)
//                        } else {
//                            EventAlarmEditor(eventGov: $eventGov)
//                        }
//
//                        if eventGov!.editField != .recurrence {
//                            EventLabelView(eventGov: $eventGov,
//                                           label: "recurrence: ",
//                                           value: String("\(eventGov!.recurrence.frequency)"),
//                                           imageString: "slider.horizontal.3",
//                                           size: 4,
//                                           target: .recurrence)
//                            .padding(.bottom)
//                        } else {
//                            EventRecurrenceEditor(eventGov: $eventGov)
//                        }
//
//                        if eventGov!.editField != .location {
//                            EventLabelView(eventGov: $eventGov,
//                                           label: "location: ",
//                                           value: eventGov!.location.isEmpty ? "none" : eventGov!.location,
//                                           imageString: "square.and.pencil",
//                                           size: 4,
//                                           target: .location)
//                        } else {
//                            EventLocationEditor(eventGov: $eventGov)
//                        }
//
//                        if eventGov!.editField != .notes {
//                            EventLabelView(eventGov: $eventGov,
//                                           label: "notes: ",
//                                           value: eventGov!.notes.isEmpty ? "none" : eventGov!.notes,
//                                           imageString: "square.and.pencil",
//                                           size: 4,
//                                           target: .notes)
//                            .padding(.bottom)
//                        } else {
//                            EventNotesEditor(eventGov: $eventGov)
//                        }
//
//                        if eventGov!.editField != .calendar {
//                            EventLabelView(eventGov: $eventGov,
//                                           label: "calendar: ",
//                                           value: eventGov!.calendar.isEmpty ? "none" : eventGov!.calendar,
//                                           imageString: "slider.horizontal.3",
//                                           size: 4,
//                                           labelColor: .gray,
//                                           target: .calendar)
//                        } else {
//                            EventCalendarEditor(eventGov: $eventGov)
//                        }
//
//                        if eventGov!.editField != .participants {
//                            EventLabelView(eventGov: $eventGov,
//                                           label: "participants: ",
//                                           value: eventGov!.participants.isEmpty ? "none" : "\(eventGov!.participants.count)",
//                                           imageString: "square.and.pencil",
//                                           size: 4,
//                                           labelColor: .gray,
//                                           target: .participants)
//                            .padding(.bottom)
//                        } else {
//                            EventParticipantEditor(eventGov: $eventGov)
//                        }
//
//                        Spacer()
//
//                        Button(action: { saveEvent() }) {
//                            HStack {
//                                Spacer()
//                                Image(systemName: "square.and.arrow.down")
//                                Text("save")
//                                Spacer()
//                            }
//                            .foregroundColor(.black)
//                            .padding(10)
//                            .background(RoundedRectangle(cornerRadius: 10).fill(.metricOrange))
//                        }
