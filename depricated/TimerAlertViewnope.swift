//
//  TimerAlertView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/30/26.
//

import SwiftUI
//
//struct TimerAlertView: View {
//    @Bindable var gov: Governor
//    @Bindable var ag: AlarmGovernor
//    
//    var body: some View {
//        GeometryReader { geometryReader in
//            let geo = gov.geoSize ?? geometryReader.size
//            ZStack {
//
//                Color(.gray)
//                    .opacity(0.2)
//                    .ignoresSafeArea()
//                
//                HStack{
//                    Spacer()
//                    VStack {
//                        Spacer()
//                        
//                        
//                        VStack(alignment: .center) {
//                            ZStack {
//                                Divider()
//                                Image(systemName: "timer")
//                            }
//                            
//                            Spacer()
//                            
//                            Text(gov.alertTxt.isEmpty ? "Timer Complete" : gov.alertTxt)
//                                .font(.title)
//                                .multilineTextAlignment(.center)
//                            
//                            Spacer()
//                            
//                            Button(action: { 
//                                gov.alert = nil 
//                            }) {
//                                VStack {
//                                    Image(systemName: "checkmark.circle.fill")
//                                    Text("Dismiss")
//                                        .font(.caption)
//                                }
//                                .foregroundStyle(.metricOrange)
//                            }
//                            .padding()
//                            
//                            Spacer()
//                        }
//                        .padding()
//                        .monospaced()
//                        .background(RoundedRectangle(cornerRadius: 30).fill(.background.opacity(0.9)))
//                        .frame(width: geo.width * 0.7, height: geo.height * 0.4)
//        
//                        
//                        Spacer()
//                    }
//                    Spacer()
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    TimerAlertView(gov: Governor(), ag: AlarmGovernor())
//}
