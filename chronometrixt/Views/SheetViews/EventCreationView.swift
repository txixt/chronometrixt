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
    @State var newEvent: MetricEvent? = nil
    @State var eventTitle: String = ""
    @State var editTitle: Bool = false
    
    
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
            
            Divider()
                .padding(.bottom)
            
            VStack {
                if newEvent == nil || editTitle == false {
                    TextField("event title", text: $eventTitle, prompt: Text("event title"))
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(.gray))
                        .onSubmit { finishEditingTitle() }
                } else {
                    Button(action: { editTitle = true }) {
                        Text(newEvent!.title)
                            .font(.title)
                            .bold()
                    }
                }
                
                Spacer()
            }
        }
        .padding()
    }
    
    private func finishEditingTitle() {
        if newEvent == nil {
            initializeEvent()
        } else {
            newEvent!.title = eventTitle
            editTitle = false
        }
    }
    
    private func initializeEvent() {
        let handler = EventHandler(modelContext: context)
        do {
            newEvent = try handler.createEvent(title: eventTitle, startTime: gov.finiteNotNow!, sequnece: 0)
        } catch {
            gov.alert = .eventCreationError
        }
    }
}

#Preview {
    EventCreationView(gov: .constant(Governor()))
}
