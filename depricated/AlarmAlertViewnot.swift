//
//  AlarmAlertView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/30/26.
//
//
//import SwiftUI
//
//struct AlarmAlertView: View {
//    @Bindable var gov: Governor
//    @Bindable var ag: AlarmGovernor
//    @Bindable var ng: NotificationGovernor
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
//                                Image(systemName: "bell.fill")
//                            }
//                            
//                            Spacer()
//                            
//                            Text(gov.alertTxt.isEmpty ? "Alarm" : gov.alertTxt)
//                                .font(.title)
//                                .multilineTextAlignment(.center)
//                            
//                            Spacer()
//                            
//                            HStack(spacing: 30) {
//                                // Snooze button
//                                Button(action: {
//                                    gov.alert = nil
//                                    ng.handleSnooze(identifier: UUID().uuidString, category: "ALARM_ALARM")
//                                }) {
//                                    VStack {
//                                        Image(systemName: "moon.zzz.fill")
//                                        Text("Snooze")
//                                            .font(.caption)
//                                    }
//                                    .foregroundStyle(.orange)
//                                }
//                                
//                                // Dismiss button
//                                Button(action: {
//                                    gov.alert = nil
//                                    ng.stopSound()
//                                }) {
//                                    VStack {
//                                        Image(systemName: "xmark.circle.fill")
//                                        Text("Dismiss")
//                                            .font(.caption)
//                                    }
//                                    .foregroundStyle(.primary)
//                                }
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
//    AlarmAlertView(gov: Governor(), ag: AlarmGovernor(), ng: NotificationGovernor())
//}
