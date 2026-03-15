//
//  DayScrollView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 1/8/26.
//

//import SwiftUI
//
//struct DayScrollView: View {
//    @Binding var gov: Governor
//    @State var days: [MetricTime] = []
//    
//    var body: some View {
//        GeometryReader { geo in
//            
//            ScrollView {
//                LazyVStack {
//                    
//                    Spacer()
//                    if !days.isEmpty {
//                        ForEach(0..<5) { day in
//                            DayMetricView(gov: $gov, day: days[day])
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
//                    var newDay = gov.finiteNotNow ?? gov.eternalNow.time
//                    newDay.day += i
//                    newDay.updateRawFromComponents()
//                    days.append(newDay)
//                }
//            }
//        }
//
//    }
//}
//
//#Preview {
//    DayScrollView(gov: .constant(Governor()))
//}
