//
//  EventEditMainView.swift
//  chronometrixt
//
//  Created by Becket on 3/19/26.
//

import SwiftUI

struct EventEditMainView: View {
    @Environment(\.modelContext) private var context
    @Bindable var gov: Governor
    @Bindable var eventGov: EventGovernor
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    if eventGov.editField != .title {
                        EventLabelView(eventGov: eventGov,
                                       label: nil,
                                       value: eventGov.title,
                                       imageString: "square.and.pencil",
                                       size: 1,
                                       titleColor: .green,
                                       target: .title)
                        .padding(.bottom)
                    } else {
                        EventTitleEditorView(eg: eventGov)
                    }
                    
                    if eventGov.editField != .startDateMetric {
                        EventLabelView(eventGov: eventGov,
                                       label: "metric start: ",
                                       value: eventGov.metricStart.fullDateTxt,
                                       imageString: "wrench",
                                       size: 2,
                                       target: .startDateMetric)
                    } else {
                        EventMetricDateEditorView(gov: gov, eg: eventGov, target: .startDateMetric)
                    }
                    
                    if eventGov.editField != .startDateGreg {
                        EventLabelView(eventGov: eventGov,
                                       label: "gregorian start: ",
                                       value: eventGov.metricStart.toGreg().formatted(),
                                       imageString: "wrench",
                                       size: 2,
                                       target: .startDateGreg)
                        .padding(.bottom)
                    } else {
                        EventGregDateEditorView(eg: eventGov, target: .startDateGreg)
                    }
                    
                    if eventGov.editField != .endDateMetric {
                        EventLabelView(eventGov: eventGov,
                                       label: "metric end: ",
                                       value: eventGov.metricEnd.fullDateTxt,
                                       imageString: "wrench",
                                       size: 2,
                                       target: .endDateMetric)
                    } else {
                        EventEndDateEditorView(gov: gov, eg: eventGov)
                    }
                    
                    if eventGov.editField != .endDateGreg {
                        EventLabelView(eventGov: eventGov,
                                       label: "gregorian end: ",
                                       value: eventGov.metricEnd.toGreg().formatted(),
                                       imageString: "wrench",
                                       size: 2,
                                       target: .endDateGreg)
                        .padding(.bottom)
                    } else {
                        EventGregDateEditorView(eg: eventGov, target: .endDateGreg)
                    }
                    
                    if eventGov.editField != .alarms {
                        EventLabelView(eventGov: eventGov,
                                       label: "alarms: ",
                                       value: eventGov.alarms.count.description,
                                       imageString: "slider.horizontal.3",
                                       size: 4,
                                       target: .alarms)
                    } else {
                        EventAlarmEditor(eg: eventGov)
                    }
                    
                    if eventGov.editField != .recurrence {
                        EventLabelView(eventGov: eventGov,
                                       label: "recurrence: ",
                                       value: String("\(eventGov.recurrence.frequency)"),
                                       imageString: "slider.horizontal.3",
                                       size: 4,
                                       target: .recurrence)
                        .padding(.bottom)
                    } else {
                        EventRecurrenceEditor(eg: eventGov)
                    }
                    
                    if eventGov.editField != .location {
                        EventLabelView(eventGov: eventGov,
                                       label: "location: ",
                                       value: eventGov.location.isEmpty ? "none" : eventGov.location,
                                       imageString: "square.and.pencil",
                                       size: 4,
                                       target: .location)
                    } else {
                        EventLocationEditor(eg: eventGov)
                    }
                    
                    if eventGov.editField != .notes {
                        EventLabelView(eventGov: eventGov,
                                       label: "notes: ",
                                       value: eventGov.notes.isEmpty ? "none" : eventGov.notes,
                                       imageString: "square.and.pencil",
                                       size: 4,
                                       target: .notes)
                        .padding(.bottom)
                    } else {
                        EventNotesEditor(eg: eventGov)
                    }
                    
                    if eventGov.editField != .calendar {
                        EventLabelView(eventGov: eventGov,
                                       label: "calendar: ",
                                       value: eventGov.calendar.isEmpty ? "none" : eventGov.calendar,
                                       imageString: "slider.horizontal.3",
                                       size: 4,
                                       labelColor: .gray,
                                       target: .calendar)
                    } else {
                        EventCalendarEditor(eg: eventGov)
                    }
                    
                    if eventGov.editField != .participants {
                        EventLabelView(eventGov: eventGov,
                                       label: "participants: ",
                                       value: eventGov.participants.isEmpty ? "none" : "\(eventGov.participants.count)",
                                       imageString: "square.and.pencil",
                                       size: 4,
                                       labelColor: .gray,
                                       target: .participants)
                        .padding(.bottom)
                    } else {
                        EventParticipantEditor(eg: eventGov)
                    }
                }
                .padding(.bottom, 150)
                
                Spacer()

            }
            
            
            VStack {
                Spacer()
                
                Button(action: { saveEvent() }) {
                    HStack {
                        Spacer()
                        Image(systemName: "square.and.arrow.down")
                        Text("save")
                        Spacer()
                    }
                    .foregroundColor(.black)
                    .bold()
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(.metricOrange))
                }
            }
        }
    }
    
    private func saveEvent() {
        let handler = EventHandler(modelContext: context)
        eventGov.itsADate(handler: handler, gov: gov)
    }
}

struct EventLabelView: View {
    @Bindable var eventGov: EventGovernor
    var label: String?
    var value: String
    var imageString: String
    var size: Int
    var titleColor: Color? = nil
    var labelColor: Color? = nil
    var target: EventGovernor.EditingFields
    
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
                    Button(action: { eventGov.editField = target }) {
                        Image(systemName: imageString)
                    }
                    .shadow(color: .gray, radius: 3)
                }
            }
        }
        .foregroundColor(labelColor ?? .primary)
    }
}

#Preview {
    EventEditMainView(
        gov: Governor(),
        eventGov: EventGovernor(
            title: "sample",
            starting: MetrixtTime(years: 5056, seconds: 123456),
            ending: MetrixtTime(years: 5056, seconds: 123459))
    )
}
