//
//  DestroyEventAlertView.swift
//  chronometrixt
//
//  Created by Becket on 3/23/26.
//

import SwiftUI
import SwiftData

struct DestroyEventAlertView: View {
    @Bindable var gov: Governor
    
    var body: some View {
        GeometryReader { geometryReader in
            let geo = gov.geoSize ?? geometryReader.size
            ZStack {
                Color(.gray).opacity(0.2).ignoresSafeArea()
                HStack{
                    Spacer()
                    VStack {
                        Spacer()
                        
                        
                        VStack {
                            ZStack {
                                Divider()
                                Text("💣")
                            }
                            
                            Spacer()
                            
                            if gov.event != nil {
                                Button(action: { gov.ec!.destroySingle() }) {
                                    VStack {
                                        Image(systemName: "trash")
                                        Text("destroy this event")
                                    }
                                    .tint(.primary)
                                    .frame(width: geo.width * 0.4)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(.red))
                                }
                            }
                            
                            if gov.event != nil && gov.event!.recurrenceRule != "NONE" {
                                Spacer()
                                
                                Button(action: { gov.ec!.destroyThisAndFuture() }) {
                                    VStack {
                                        HStack {
                                            Image(systemName: "trash")
                                            Image(systemName: "trash")
                                            Image(systemName: "trash")
                                        }
                                        Text("erase this and future events")
                                    }
                                    .tint(.primary)
                                    .frame(width: geo.width * 0.4)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(.red))
                                }
                                
                                Spacer()
                                
                                Button(action: { gov.ec!.destroySeries()} ) {
                                    VStack {
                                        HStack {
                                            Image(systemName: "trash")
                                            Image(systemName: "trash")
                                            Image(systemName: "trash")
                                            Image(systemName: "trash")
                                            Image(systemName: "trash")
                                        }
                                        Text("obliterate this from the timeline")
                                    }
                                    .tint(.primary)
                                    .frame(width: geo.width * 0.4)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(.red))
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
    @Previewable @Environment(\.modelContext) var context
    DestroyEventAlertView(gov: Governor(context: context))
}
