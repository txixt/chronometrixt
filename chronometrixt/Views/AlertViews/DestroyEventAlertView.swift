//
//  DestroyEventAlertView.swift
//  chronometrixt
//
//  Created by Becket on 3/23/26.
//

import SwiftUI

struct DestroyEventAlertView: View {
    @Bindable var gov: Governor
    @Bindable var eg: EventGovernor
    
    var body: some View {
        GeometryReader { geometryReader in
            let geo = gov.geoSize ?? geometryReader.size
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
                                Button(action: { eg.destroySingle() }) {
                                    VStack {
                                        Image(systemName: "trash")
                                        Text("destroy this event?")
                                    }
                                    .tint(.red)
                                    .shadow(color: .red, radius: 3)
                                }
                            }
                            
                            if gov.event != nil && gov.event!.recurrenceRule != "NONE" {
                                Spacer()
                                
                                Button(action: { eg.destroyThisAndFuture() }) {
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
                        .background(RoundedRectangle(cornerRadius: 30).fill(.background.opacity(0.9)))
                        .frame(width: geo.width * 0.5, height: geo.height * 0.5)
        
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    DestroyEventAlertView(gov: Governor(), eg: PreviewEG().eg())
}
