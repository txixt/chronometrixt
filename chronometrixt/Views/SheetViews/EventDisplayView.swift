//
//  EventDisplayView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/22/26.
//

import SwiftUI

struct EventDisplayView: View {
    @Bindable var gov: Governor
    @Bindable var eg: EventGovernor
    
    var body: some View {
        let truncatedTitl: String = eg.title.split(separator: " ", maxSplits: 2).prefix(2).joined(separator: " ")
        
        VStack {
            
            SheetHeaderView(gov: gov, title: truncatedTitl, titleImage: "fleuron")
            
            HStack {
                VStack(alignment: .leading) {
                    Text(eg.title)
                        .tint(Color(hex: eg.calendarColor))
                        .font(.title)
                        .padding(.bottom)
                    
                    Text("starts: ")
                        .font(.caption)
                    Text(eg.metricStart.fullDateTxt)
                        .font(.title2)
                    Text(eg.gregStart.formatted())
                        .padding(.bottom)
                    
                    VStack(alignment: .leading) {
                        Text("ends: ")
                            .font(.caption)
                        Text(eg.isAllDay ? "all day" : eg.metricEnd.fullDateTxt)
                            .font(.title2)
                        if !eg.isAllDay {
                            Text(eg.gregEnd.formatted())
                        }
                    }
                    .padding(.bottom)
                    
                    MetrixtSubdivider()
                    
                    HStack(alignment: .top, spacing: 0) {
                        HStack {
                            Spacer()
                            Text("recurrence: ")
                                .font(.caption)
                        }
                        .frame(width: 100)
                        VStack(alignment: .leading) {
                            if eg.recurrence != .none {
                                Text(String(
                                    "\(eg.recurrence.frequency)" +
                                    (eg.recurrence.frequency == .none && eg.recurrence.count == nil ? "" :
                                    (eg.recurrence.count == nil ? " x ∞" : " x \(eg.recurrence.count!)"))
                                                ))
                            } else {
                                Text("one-time event")
                            }
                        }
                    }

                    HStack(alignment: .top, spacing: 0) {
                        HStack {
                            Spacer()
                            Text("alarms: ")
                                .font(.caption)
                        }
                        .frame(width: 100)
                        VStack(alignment: .leading) {
                            Text("\(eg.alarms.count.description)")
                        }
                    }
                    .padding(.bottom)
                    
                    HStack(alignment: .top, spacing: 0) {
                        HStack {
                            Spacer()
                            Text("location: ")
                                .font(.caption)
                        }
                        .frame(width: 100)
                        VStack(alignment: .leading) {
                            if !eg.location.isEmpty {
                                if MapInsetView(location: eg.location).didSearch == true {
                                    MapInsetView(location: eg.location)
                                } else {
                                    Text(eg.location)
                                }
                            } else {
                                Text("none")
                            }
                        }
                    }
                    HStack(alignment: .top, spacing: 0) {
                        HStack {
                            Spacer()
                            Text("notes: ")
                                .font(.caption)
                        }
                        .frame(width: 100)
                        VStack(alignment: .leading) {
                            Text(eg.notes.isEmpty ? "none" : eg.notes)
                        }
                    }
                    .padding(.bottom)
                    
                    HStack(alignment: .top, spacing: 0) {
                        HStack {
                            Spacer()
                            Text("calendar: ")
                                .font(.caption)
                        }
                        .frame(width: 100)
                        VStack(alignment: .leading) {
                            Text(eg.calendar)
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(.gray)
                }
                .bold()
                
                Spacer()
                

            }
            
            
            Spacer()
            
            ZStack {
                Divider()
                HStack {
                    Text("edit")
                        .font(.title3)
                        .foregroundStyle(.primary)
                        .bold()
                    Spacer()
                    Button(action: { gov.sheet = .editEvent }) {
                        Image(systemName: "wrench")
                    }
                    .tint(.primary)
                    .shadow(color: .gray, radius: 3)
                }
            }
        }
        .monospaced()
        .padding()
    }
}

#Preview {
    EventDisplayView(gov: Governor(), eg: PreviewEG().eg())
}
