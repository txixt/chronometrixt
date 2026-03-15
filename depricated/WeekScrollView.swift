//
//  WeekScrollView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 1/12/26.
//

//import SwiftUI
//
//struct WeekScrollView: View {
//    @Binding var gov: Governor
//    @State var weeks: [MetricTime] = []
//    
//    var body: some View {
//        GeometryReader { geo in
//            
//            ScrollView {
//                LazyVStack {
//                    
//                    Spacer()
//                    if !weeks.isEmpty {
//                        ForEach(0..<5) { week in
//                            WeekMetricView(gov: $gov, week: weeks[week])
//                                .frame(height: geo.size.height * 0.6)
//                                .padding()
//                        }
//                    }
//                    Spacer()
//                    
//                }
//            }
//            .onAppear() {
//                for i in -2..<3 {
//                    var newWeek = gov.finiteNotNow ?? gov.eternalNow.time
//                    newWeek.week += i
//                    newWeek.updateRawFromComponents()
//                    weeks.append(newWeek)
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    WeekScrollView(gov: .constant(Governor()))
//}
