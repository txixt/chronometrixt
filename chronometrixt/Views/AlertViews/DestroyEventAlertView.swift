//
//  DestroyEventAlertView.swift
//  chronometrixt
//
//  Created by Becket on 3/23/26.
//

import SwiftUI

struct DestroyEventAlertView: View {
    @Environment(\.modelContext) private var context
    @Bindable var gov: Governor
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                HStack{
                    Spacer()
                    VStack {
                        Spacer()
                        
                        
                        VStack {
                            Spacer()
                            ZStack {
                                Divider()
                                Text("💣")
                                    .font(.largeTitle)
                            }
                            
                            Spacer()
                            
                            if gov.event != nil {
                                Button(action: {}) {
                                    VStack {
                                        Image(systemName: "trash")
                                        Text("destroy this event?")
                                    }
                                    .tint(.red)
                                    .shadow(color: .red, radius: 3)
                                }
                            }
                            
                            if gov.event != nil && gov.event!.recurrenceRule.count > 0 {
                                Button(action: {}) {
                                    VStack {
                                        HStack {
                                            Image(systemName: "trash")
                                            Image(systemName: "trash")
                                            Image(systemName: "trash")
                                        }
                                        Text("destroy this and future events?")
                                    }
                                    .tint(.red)
                                    .shadow(color: .red, radius: 3)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: { gov.alert = nil }) {
                                Image(systemName: "plus")
                                    .tint(.primary)
                                    .rotationEffect(Angle(degrees: 45))
                                    .shadow(color: .gray, radius: 3)
                                    .bold()
                            }
                            
                            
                            
                            Spacer()
                        }
                        .padding()
                        .monospaced()
                        .background(RoundedRectangle(cornerRadius: 30).fill(.gray.opacity(0.2)))
                        .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.5)
        
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
    
    private func destroyEvent() {
        let handler = EventHandler(modelContext: context)
        handler.destroySingleEvent(gov.event!)
    }
    
    private func destroyAllEvents() {
        let handler = EventHandler(modelContext: context)
        handler.destroyThisAndFuture(gov.event!)
    }
}

#Preview {
    DestroyEventAlertView(gov: Governor())
}
