//
//  EventEditMainView.swift
//  chronometrixt
//
//  Created by Becket on 3/19/26.
//

import SwiftUI
import SwiftData

struct EventEditMainView: View {
    @Query var calendars: [MetricCalendar]
    @Bindable var gov: Governor
    let update: Bool
    
    var body: some View {
        if gov.ec != nil {
            GeometryReader { geometryReader in
                let geo = gov.geoSize ?? geometryReader.size
                VStack {
                    ScrollView {
                            VStack {
                                if gov.ec!.editField != .title {
                                    EventLabelView(eventGov: gov.ec!,
                                                   label: nil,
                                                   value: gov.ec!.title,
                                                   imageString: "square.and.pencil",
                                                   size: 1,
                                                   titleColor: Color(hex: gov.ec!.calendarColor),
                                                   target: .title)
                                    .padding(.bottom)
                                } else {
                                    EventTitleEditorView(eg: gov.ec!)
                                }
                                
                                if gov.ec!.editField != .startDateMetric {
                                    EventLabelView(eventGov: gov.ec!,
                                                   label: "metric start: ",
                                                   value: gov.ec!.metricStart.fullDateTxt,
                                                   imageString: "wrench",
                                                   size: 2,
                                                   target: .startDateMetric)
                                } else {
                                    EventMetricDateEditorView(gov: gov, eg: gov.ec!, target: .startDateMetric)
                                }
                                
                                if gov.ec!.editField != .startDateGreg {
                                    EventLabelView(eventGov: gov.ec!,
                                                   label: "gregorian start: ",
                                                   value: gov.ec!.metricStart.toGreg().formatted(),
                                                   imageString: "wrench",
                                                   size: 2,
                                                   target: .startDateGreg)
                                    .padding(.bottom)
                                } else {
                                    EventGregDateEditorView(eg: gov.ec!, target: .startDateGreg)
                                }
                                
                                if gov.ec!.editField != .endDateMetric {
                                    EventLabelView(eventGov: gov.ec!,
                                                   label: "metric end: ",
                                                   value: gov.ec!.isAllDay ? "all day" : gov.ec!.metricEnd.fullDateTxt,
                                                   imageString: "wrench",
                                                   size: 2,
                                                   target: .endDateMetric)
                                } else {
                                    EventEndDateEditorView(gov: gov, eg: gov.ec!)
                                }
                                
                                if gov.ec!.editField != .endDateGreg {
                                    EventLabelView(eventGov: gov.ec!,
                                                   label: "gregorian end: ",
                                                   value: gov.ec!.isAllDay ? "all day" : gov.ec!.metricEnd.toGreg().formatted(),
                                                   imageString: "wrench",
                                                   size: 2,
                                                   target: .endDateGreg)
                                    .padding(.bottom)
                                } else {
                                    EventEndDateGregEditorView(gov: gov , eg: gov.ec!)
                                }
                                
                                if gov.ec!.editField != .alarms {
                                    EventLabelView(eventGov: gov.ec!,
                                                   label: "alarms: ",
                                                   value: gov.ec!.alarms.count.description,
                                                   imageString: gov.ec!.alarms.isEmpty ? "bell" : "bell.fill",
                                                   size: 4,
                                                   target: .alarms)
                                } else {
                                    EventAlarmEditorView(eg: gov.ec!)
                                }
                                
                                if gov.ec!.editField != .recurrence {
                                    EventLabelView(eventGov: gov.ec!,
                                                   label: "recurrence: ",
                                                   value: String(
                                                    "\(gov.ec!.recurrence.frequency)" +
                                                    (gov.ec!.recurrence.frequency == .none && gov.ec!.recurrence.count == nil ? "" :
                                                    (gov.ec!.recurrence.count == nil ? " x ∞" : " x \(gov.ec!.recurrence.count!)"))
                                                                ),
                                                   imageString: gov.ec!.recurrence.frequency == .none ? "square.stack.3d.down.right" : "square.stack.3d.down.right.fill",
                                                   size: 4,
                                                   target: .recurrence)
                                    .padding(.bottom)
                                } else {
                                    EventRecurrenceEditorView(eg: gov.ec!, chronologyError: chronologyError)
                                }
                                
                                if gov.ec!.editField != .location {
                                    EventLabelView(eventGov: gov.ec!,
                                                   label: "location: ",
                                                   value: gov.ec!.location.isEmpty ? "none" : gov.ec!.location,
                                                   imageString: "square.and.pencil",
                                                   size: 4,
                                                   target: .location)
                                } else {
                                    EventLocationEditorView(eg: gov.ec!)
                                }
                                
                                if gov.ec!.editField != .notes {
                                    EventLabelView(eventGov: gov.ec!,
                                                   label: "notes: ",
                                                   value: gov.ec!.notes.isEmpty ? "none" : gov.ec!.notes,
                                                   imageString: "square.and.pencil",
                                                   size: 4,
                                                   target: .notes)
                                    .padding(.bottom)
                                } else {
                                    EventNotesEditorView(eg: gov.ec!)
                                }
                                
                                if calendars.count > 1 {
                                    if gov.ec!.editField != .calendar {
                                        EventLabelView(eventGov: gov.ec!,
                                                       label: "calendar: ",
                                                       value: gov.ec!.calendar.isEmpty ? "none" : gov.ec!.calendar,
                                                       imageString: "slider.horizontal.3",
                                                       size: 4,
                                                       labelColor: .gray,
                                                       target: .calendar)
                                    } else {
                                        EventCalendarEditorView(eg: gov.ec!)
                                    }
                                }

                                if !gov.ec!.participants.isEmpty {
                                    if gov.ec!.editField != .participants {
                                        EventLabelView(eventGov: gov.ec!,
                                                       label: "participants: ",
                                                       value: "\(gov.ec!.participants.count)",
                                                       imageString: "eye",
                                                       size: 4,
                                                       labelColor: .gray,
                                                       target: .participants)
                                        .padding(.bottom)
                                    } else {
                                        EventParticipantView(eg: gov.ec!)
                                    }
                                }
                            }
                            .padding(.bottom, 50)
                            
                            Spacer()
                            
                            if update {
                                ZStack {
                                    Divider()
                                    HStack {
                                        Text("destroy event")
                                            .font(.title3)
                                            .foregroundStyle(.secondary)
                                            .bold()
                                        Spacer()
                                        Button(action: destroyEvent) {
                                            Image(systemName: "trash")
                                        }
                                        .tint(.red)
                                        .shadow(color: .red, radius: 3)
                                    }
                                }
                            }
                        }
                    
                    Spacer()
                    
                    Button(action: update ? updateEvent : saveEvent) {
                        HStack {
                            Spacer()
                            Image(systemName: "square.and.arrow.down")
                            Text(update ? "update" : "save")
                            Spacer()
                        }
                        .foregroundColor(.black)
                        .bold()
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(.metricOrange))
                    }
                    .padding(.bottom)
                    
                }
                .frame(height: geo.height)
            }
        }
    }
    
    private func destroyEvent() {
        gov.alert = .destroyEvent
    }
    
    private func saveEvent() {
        gov.ec!.save()
    }
    
    private func updateEvent() {
        gov.ec!.update()
    }
    
    func chronologyError() {
        gov.alertTxt = "the arrow of time is immutable. please pick a date after origin."
        gov.alert = .error
    }
}

struct EventLabelView: View {
    @Bindable var eventGov: EventComptroller
    var label: String?
    var value: String
    var imageString: String
    var size: Int
    var titleColor: Color? = nil
    var labelColor: Color? = nil
    var target: EventComptroller.EditingFields
    
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
//    let context = PreviewEG.previewContainer.mainContext
//    let gov = Governor()
//    gov.ec = EventComptroller(
//        title: "sample",
//        starting: MetrixtTime(years: 5056, seconds: 123456),
//        ending: MetrixtTime(years: 5056, seconds: 123459),
//        context: context,
//        gov: gov)
    EventEditMainView(
        gov: Governor(),
        update: true
    )
}

//struct PreviewWrapper: View {
//    @FocusState var focus: EventCreationView.FocusField?
//    var body: some View {
//        EventTitleEditorView(
//            eg: EventGovernor(
//                title: "sample",
//                starting: MetrixtTime(years: 5056, seconds: 123456),
//                ending: MetrixtTime(years: 5056, seconds: 123459)),
//            focus: $focus
//        )
//    }
//}
//return PreviewWrapper()
