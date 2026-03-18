//
//  EventCreationView.swift
//  chronometrixt
//
//  Created by Becket on 3/17/26.
//

import SwiftUI

struct EventCreationView: View {
    @Environment(\.modelContext) private var context
    @Binding var gov: Governor
    @State var eventGov: EventGovernor? = nil
    @State var eventTitle: String = ""
    
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "plus")
                Text("new event")
                Spacer()
                Button(action: { gov.sheet = .none }) {
                    Image(systemName: "plus")
                        .rotationEffect(Angle(degrees: 45))
                        .shadow(color: .gray, radius: 3)
                }
            }
            .font(.largeTitle.bold())
            .foregroundStyle(.primary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 2.5).frame(width: 100, height: 5)
                Divider()
            }

                .padding(.bottom)
            
            VStack {
                if eventGov == nil || eventGov!.editTitle == true {
                    VStack(alignment: .leading) {

                        Text("event title:")
                        TextField("event title", text: $eventTitle, prompt: Text("event title"))
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(.gray))
                            .onSubmit { finishEditingTitle() }
                    }
                } else if eventGov != nil {
                    Button(action: { eventGov!.editTitle = true }) {
                        HStack {
                            Text(eventGov!.title)
                                .font(.title)
                                .bold()
                            Spacer()
                        }
                        .foregroundColor(.primary)
                    }
                    .padding(.bottom)
                }
                
                if eventGov != nil {
                    VStack {
                        
                        ZStack {
                            
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("metric event date:")
                                        .font(.caption)
                                    Text(gov.finiteNotNow!.fullDateTxt)
                                        .font(.title3)
                                        .bold()
                                }

                                Spacer()
                                Button(action: { editStartDateMetric() }) {
                                    VStack {
                                        Image(systemName: "wrench.adjustable.fill")
                                            .font(.title2)
                                            .shadow(color: .gray, radius: 3)
                                        Text("adjust metrically")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.primary)
                                    .frame(width: 100, height: 100)
                                }
                            }
                            
                        }
                        ZStack {
                            
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("gregorian event date:")
                                        .font(.caption)
                                    Text(gov.finiteNotNow!.toGreg().formatted())
                                        .font(.title3)
                                        .bold()
                                }

                                Spacer()
                                Button(action: { editStartDateGreg() }) {
                                    VStack {
                                        Image(systemName: "wrench.adjustable.fill")
                                            .scaleEffect(x: -1.0)
                                            .font(.title2)
                                            .shadow(color: .gray, radius: 3)
                                        Text("ye olde adjustments")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.primary)
                                    .frame(width: 100, height: 100)
                                }
                            }
                            
                        }
                        ZStack {
                            
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(gov.finiteNotNow!.fullDateTxt)
                                        .font(.title3)
                                        .bold()
                                    Text(gov.finiteNotNow!.toGreg().formatted())
                                        .font(.title3)
                                        .bold()
                                }

                                Spacer()
                                Button(action: { editStartDateGreg() }) {
                                    VStack {
                                        ZStack {
                                            Image(systemName: "clock")
                                                .foregroundColor(.gray)
                                            Image(systemName: "checkmark").bold()
                                        }
                                        .font(.title2)
                                        .shadow(color: .gray, radius: 3)
                                        Text("use this time")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.primary)
                                    .frame(width: 100, height: 100)
                                }
                            }
                            
                        }

                    }
                }
                
                
                Spacer()
            }
        }
        .padding()
        .monospaced()
    }
    
    private func editStartDateMetric() {
        
    }
    
    private func editStartDateGreg() {
        
    }
    
    private func editEndDateMetric() {
        
    }
    
    private func editEndDateGreg() {
        
    }
    
    private func finishEditingTitle() {
        guard !eventTitle.isEmpty else { return }
        if eventGov == nil {
            initializeEvent()
        } else {
            eventGov!.title = eventTitle
            eventGov!.editTitle = false
        }
    }
    
    private func initializeEvent() {
        if gov.finiteNotNow == nil { gov.finiteNotNow = gov.eternalNow.time }
        eventGov = EventGovernor(title: eventTitle, starting: gov.finiteNotNow!, ending: metric.cal.update(time: gov.finiteNotNow!, component: .second, byAdding: 1))
    }
}

#Preview {
    EventCreationView(gov: .constant(Governor()))
}
