//
//  EventAlertView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/30/26.
//

import SwiftUI
import SwiftData

struct EventAlertView: View {
    @Bindable var gov: Governor
    
    var body: some View {
        GeometryReader { geometryReader in
            let geo = gov.geoSize ?? geometryReader.size
            ZStack {

                Color(.gray)
                    .opacity(0.2)
                    .ignoresSafeArea()
                
                HStack{
                    Spacer()
                    VStack {
                        Spacer()
                        
                        
                        VStack(alignment: .center) {
                            ZStack {
                                Divider()
                                Image(systemName: "fleuron")
                            }
                            
                            Spacer()
                            
                            Text(gov.alertTxt.isEmpty ? "an event is eventing" : "event \(gov.alertTxt) is imminent")
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                            
                            Button(action: goToEvent) {
                                Text("which event?")
                            }
                            .tint(.primary)
                            .padding()
                            .frame(width: geo.width * 0.4)
                            .background(RoundedRectangle(cornerRadius: 10).fill(.metricOrange))
                            
                            
                            Spacer()
                            
                            Button(action: tidyUp) {
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
    
    private func goToEvent() {
        gov.sheet = .showEvent
        tidyUp()
    }

    private func tidyUp() {
        gov.alertTxt = ""
        gov.alert = nil
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var context
    EventAlertView(gov: Governor())
}
