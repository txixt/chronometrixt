//
//  MetricDayView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/31/25.
//
//
//import SwiftUI
//
//struct MetricDayView: View {
//    @Binding var gov: Governor
//    
//    var body: some View {
//        let functionalTime = gov.finiteNotNow ?? gov.eternalNow.time
//        
//        GeometryReader { geo in
//            VStack{
//                Spacer()
//                
//                Button(action: openYear) {
//                    HStack {
//                        Text(functionalTime.yearTxt + " • " + functionalTime.mwdTxt)
//                            .font(.largeTitle).bold()
//                            .foregroundColor(gov.finiteNotNow == nil ? .metricOrange : .primary)
//                        Spacer()
//                    }
//                    .padding(.bottom)
//                }
//
//                VStack {
//                    HStack {
//                        Text(MetricLogic.months[functionalTime.month] + " " + MetricLogic.weeks[functionalTime.week] + " " + MetricLogic.days[functionalTime.day])
//                            .foregroundColor(gov.finiteNotNow == nil && functionalTime.month == gov.eternalNow.time.month ? .metricOrange : .primary)
//                            .font(.system(size: 22)).bold()
//                            Spacer()
//                    }
//                    .padding(.bottom)
//                    
//                    VStack {
//                        LazyHGrid(rows: Array(repeating: GridItem(.flexible(minimum: 20, maximum: 20)), count: 10)) {
//                            ForEach(MetricLogic.hours, id: \.self) {  hourName in
//                                Button(action: {}) {
//                                    ZStack {
//                                        Divider()
//                                        HStack {
//                                            Text(hourName)
//                                                .foregroundColor(.primary)
//                                            Spacer()
//                                        }
//                                    }
//                                }
//                                .frame(width: geo.size.width)
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//                
//                Spacer()
//            }
//            .monospaced()
//        }
//    }
//    
//    private func openYear() {
//        gov.scale = .year
//    }
//}
//
//#Preview {
//    MetricDayView(gov: .constant(Governor()))
//}
