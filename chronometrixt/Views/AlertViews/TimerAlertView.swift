//
//  TimerAlertView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/30/26.
//

import SwiftUI

struct TimerAlertView: View {
    @Bindable var gov: Governor
    @Bindable var ag: AlarmGovernor
    
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
                                Image(systemName: "timer")
                            }
                            
                            Spacer()
                            
                            Text(gov.alertTxt.isEmpty ? "timer done timed " : "timer \(gov.alertTxt) done timed")
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                            
                            Button(action: goToTimer) {
                                Text("show me")
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
    
    private func goToTimer() {
        gov.sheet = .timers
        ag.mode = .timer
        tidyUp()
    }

    private func tidyUp() {
        gov.alertTxt = ""
        gov.alert = nil
    }
}

#Preview {
    TimerAlertView(gov: Governor(), ag: AlarmGovernor())
}
