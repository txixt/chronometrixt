//
//  AlarmAlertView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/30/26.
//

import SwiftUI

struct AlarmAlertView: View {
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
                                Image(systemName: "alarm")
                            }
                            
                            Spacer()
                            
                            Text(gov.alertTxt.isEmpty ? "alarm done alarmed" : "alarm \(gov.alertTxt) done alarmed")
                                .multilineTextAlignment(.center)
                                
                            
                            Spacer()
                            
                            Button(action: goToTimer) {
                                Text("show me")
                            }
                            .tint(.primary).bold()
                            .padding()
                            .frame(width: geo.width * 0.4)
                            .background(RoundedRectangle(cornerRadius: 10).fill(.metricOrange))
                            
                            
                            Spacer()
                            Button(action: goToTimer) {
                                Text("snooze")
                            }
                            .tint(.primary).bold()
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
    
    private func snooze() {
        ///HANDLE SNOOZE
    }
    
    private func goToTimer() {
        gov.sheet = .timers
        gov.ac.mode = .alarm
        tidyUp()
    }

    private func tidyUp() {
        gov.alertTxt = ""
        gov.alert = nil
    }
}

#Preview {
    AlarmAlertView(gov: Governor())
}
