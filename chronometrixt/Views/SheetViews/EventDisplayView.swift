//
//  EventDisplayView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/22/26.
//

import SwiftUI
import SwiftData

struct EventDisplayView: View {
    @Bindable var gov: Governor
    
    var body: some View {
        let truncatedTitl: String = gov.ec!.title.split(separator: " ", maxSplits: 2).prefix(2).joined(separator: " ")
        
        ZStack {
            VStack {
                
                SheetHeaderView(gov: gov, title: truncatedTitl, titleImage: "fleuron")
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(gov.ec!.title)
                            .foregroundStyle(Color(hex: gov.ec!.calendarColor))
                            .font(.title)
                            .padding(.bottom)
                        
                        Text("starts: ")
                            .font(.caption)
                        Text(gov.ec!.metricStart.fullDateTxt)
                            .font(.title2)
                        Text(gov.ec!.gregStart.formatted())
                            .padding(.bottom)
                        
                        VStack(alignment: .leading) {
                            Text("ends: ")
                                .font(.caption)
                            Text(gov.ec!.isAllDay ? "all day" : gov.ec!.metricEnd.fullDateTxt)
                                .font(.title2)
                            if !gov.ec!.isAllDay {
                                Text(gov.ec!.gregEnd.formatted())
                            }
                        }
                        .padding(.bottom)
                        
                        VStack(alignment: .leading) {
                            if !gov.ec!.location.isEmpty {
                                MapInsetView(location: gov.ec!.location)
                                    .tint(.primary)
                            } else {
                                Text("none")
                            }
                        }
                        
                        MetrixtSubdivider()
                        
                        HStack(alignment: .top, spacing: 0) {
                            HStack {
                                Spacer()
                                Text("recurrence: ")
                            }
                            .frame(width: 100)
                            VStack(alignment: .leading) {
                                if gov.ec!.recurrence != .none {
                                    Text(String(
                                        "\(gov.ec!.recurrence.frequency)" +
                                        (gov.ec!.recurrence.frequency == .none && gov.ec!.recurrence.count == nil ? "" :
                                        (gov.ec!.recurrence.count == nil ? " x ∞" : " x \(gov.ec!.recurrence.count!)"))
                                                    ))
                                } else {
                                    Text("one-time event")
                                }
                            }
                        }
                        .font(.caption)

                        HStack(alignment: .top, spacing: 0) {
                            HStack {
                                Spacer()
                                Text("alarms: ")
                            }
                            .frame(width: 100)
                            VStack(alignment: .leading) {
                                Text("\(gov.ec!.alarms.count.description)")
                            }
                        }
                        .font(.caption)
                        .padding(.bottom)
                        
                        HStack(alignment: .top, spacing: 0) {
                            HStack {
                                Spacer()
                                Text("notes: ")
                                    .font(.caption)
                            }
                            .frame(width: 100)
                            VStack(alignment: .leading) {
                                ScrollView {
                                    Text(gov.ec!.notes.isEmpty ? "none" : gov.ec!.notes)
                                }
                                .frame(maxHeight: 150)
                            }
                        }
                        .padding(.bottom)
                        
    //                    HStack(alignment: .top, spacing: 0) {
    //                        HStack {
    //                            Spacer()
    //                            Text("calendar: ")
    //                                .font(.caption)
    //                        }
    //                        .frame(width: 100)
    //                        VStack(alignment: .leading) {
    //                            Text(eg.calendar)
    //                                .font(.caption)
    //                        }
    //                    }
    //                    .foregroundStyle(.gray)
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
            
            AlertView(gov: gov)
        }

    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var context
    EventDisplayView(gov: Governor(context: context))
}
