//
//  YearMetricScrollView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 1/11/26.
//

import SwiftUI

//struct YearMetricScrollView: View {
//    @Binding var gov: Governor
////    @State private var currentYearOffset: Int = 0
//    @State var yearScroll: [MetricTime] = []
//    
//    private var drag: some Gesture {
//        DragGesture()
//
//            .onEnded { value in
//                guard value.startLocation.y != value.predictedEndLocation.y else { return }
//                withAnimation(.easeInOut) {
//                    gov.finiteNotNow = yearScroll[value.startLocation.y < value.predictedEndLocation.y ? 1 : 3]
//                    if gov.finiteNotNow!.year == gov.eternalNow.time.year {
//                        gov.finiteNotNow = nil
//                    }
//                    populateScroll()
//                }
//            }
//    }
//    
//    var body: some View {
//        var someTime: MetricTime { gov.finiteNotNow ?? gov.eternalNow.time }
//        
//        GeometryReader { geo in
//            VStack {
//                ForEach(yearScroll, id: \.year) { date in
//                    MetricYearView(gov: $gov, year: date)
//                        .opacity(someTime.year == date.year ? 1.0 : 0.5)
//                }
//                .offset(y: -geo.size.height * 1.35)
//            }
//            .gesture(drag)
////            .frame(maxWidth: .infinity, maxHeight: .infinity)
//        }
//        .onAppear() {
//            populateScroll()
//        }
//    }
//    
//    private func populateScroll() {
//        yearScroll = {
//            (-2...2).map { offset in
//                var year = gov.finiteNotNow ?? gov.eternalNow.time
//                let totalOffset = currentYearOffset + offset
//                year.raw += Double(totalOffset * 100_000_000)
//                year.year += totalOffset
//                return year
//            }
//        }()
//    }
//}
//
//#Preview {
//    YearMetricScrollView(gov: .constant(Governor()))
//}

