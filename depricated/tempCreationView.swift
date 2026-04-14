//
//  tempCreationView.swift
//  chronometrixt
//
//  Created by Becket on 3/18/26.
//

//import SwiftUI
//
//struct tempCreationView: View {
//    @Environment(\.modelContext) private var context
//    @Binding var gov: Governor
//    @State var eventGov: EventGovernor? = EventGovernor(
//        title: "sample",
//        starting: MetrixtTime(date: Date(timeIntervalSince1970: TimeInterval(10.0))),
//        ending: MetrixtTime(date: Date(timeIntervalSince1970: TimeInterval(11.0))))
//    @State var eventTitle: String = ""
//    
//    
//    var body: some View {
//        VStack {
//            HStack {
//                Image(systemName: "plus")
//                Text("new event")
//                Spacer()
//                Button(action: { gov.sheet = .none }) {
//                    Image(systemName: "plus")
//                        .rotationEffect(Angle(degrees: 45))
//                        .shadow(color: .gray, radius: 3)
//                }
//            }
//            .font(.largeTitle.bold())
//            .foregroundStyle(.primary)
//            
//            ZStack {
//                RoundedRectangle(cornerRadius: 2.5).frame(width: 100, height: 5)
//                Divider()
//            }
//            .padding(.bottom)
//            
//            EventLabelView(eventGov: $eventGov,
//                           label: nil,
//                           value: eventGov!.title,
//                           imageString: "square.and.pencil",
//                           size: 1,
//                           titleColor: .green,
//                           target: .title)
//                .padding(.bottom)
//            
//            EventLabelView(eventGov: $eventGov,
//                           label: "metric start: ",
//                           value: eventGov!.metricStart.fullDateTxt,
//                           imageString: "wrench",
//                           size: 2,
//                           target: .startDateMetric)
//            EventLabelView(eventGov: $eventGov,
//                           label: "gregorian start: ",
//                           value: eventGov!.metricStart.toGreg().formatted(),
//                           imageString: "wrench",
//                           size: 2,
//                           target: .startDateGreg)
//                .padding(.bottom)
//            
//
//            EventLabelView(eventGov: $eventGov,
//                           label: "metric end: ",
//                           value: eventGov!.metricEnd.fullDateTxt,
//                           imageString: "wrench",
//                           size: 2,
//                           target: .endDateMetric)
//            EventLabelView(eventGov: $eventGov,
//                           label: "gregorian end: ",
//                           value: eventGov!.metricEnd.toGreg().formatted(),
//                           imageString: "wrench",
//                           size: 2,
//                           target: .endDateGreg)
//                .padding(.bottom)
//            
//            EventLabelView(eventGov: $eventGov,
//                           label: "alarms: ",
//                           value: eventGov!.alarms.count.description,
//                           imageString: "slider.horizontal.3",
//                           size: 4,
//                           target: .alarms)
//            EventLabelView(eventGov: $eventGov,
//                           label: "recurrence: ",
//                           value: String("\(eventGov!.recurrence.frequency)"),
//                           imageString: "slider.horizontal.3",
//                           size: 4,
//                           target: .recurrence)
//                .padding(.bottom)
//            
//            EventLabelView(eventGov: $eventGov,
//                           label: "location: ",
//                           value: eventGov!.location.isEmpty ? "none" : eventGov!.location,
//                           imageString: "square.and.pencil",
//                           size: 4,
//                           target: .location)
//            EventLabelView(eventGov: $eventGov,
//                           label: "notes: ",
//                           value: eventGov!.notes.isEmpty ? "none" : eventGov!.location,
//                           imageString: "square.and.pencil",
//                           size: 4,
//                           target: .notes)
//                .padding(.bottom)
//            
//            EventLabelView(eventGov: $eventGov,
//                           label: "calendar: ",
//                           value: eventGov!.location.isEmpty ? "none" : eventGov!.location,
//                           imageString: "slider.horizontal.3",
//                           size: 4,
//                           labelColor: .gray,
//                           target: .calendar)
//            EventLabelView(eventGov: $eventGov,
//                           label: "participants: ",
//                           value: eventGov!.notes.isEmpty ? "none" : eventGov!.location,
//                           imageString: "square.and.pencil",
//                           size: 4,
//                           labelColor: .gray,
//                           target: .participants)
//                .padding(.bottom)
//
//            Spacer()
//            
//            Button(action: {}) {
//                HStack {
//                    Spacer()
//                    Image(systemName: "square.and.arrow.down")
//                    Text("save")
//                    Spacer()
//                }
//                .foregroundColor(.black)
//                .padding(10)
//                .background(RoundedRectangle(cornerRadius: 10).fill(.metricOrange))
//            }
//        }
//        .padding()
//        .monospaced()
//    }
//    
//    private func editStartDateMetric() {
//        
//    }
//    
//    private func editStartDateGreg() {
//        
//    }
//    
//    private func editEndDateMetric() {
//        
//    }
//    
//    private func editEndDateGreg() {
//        
//    }
//    
//    private func finishEditingTitle() {
//        guard !eventTitle.isEmpty else { return }
//        if eventGov == nil {
//            initializeEvent()
//        } else {
//            eventGov!.title = eventTitle
//            eventGov!.editTitle = false
//        }
//    }
//    
//    private func initializeEvent() {
//        if gov.finiteNotNow == nil { gov.finiteNotNow = gov.eternalNow.time }
//        eventGov = EventGovernor(title: eventTitle, starting: gov.finiteNotNow!, ending: metric.cal.update(time: gov.finiteNotNow!, component: .second, byAdding: 1))
//    }
//}
//
//
//
//#Preview {
//    tempCreationView(gov: .constant(Governor()))
//}
