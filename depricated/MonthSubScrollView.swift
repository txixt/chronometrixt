//
//  MonthSubScrollView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 1/13/26.
//

//import SwiftUI
//
//struct MonthSubScrollView: View {
//    @Binding var gov: Governor
//    @State private var monthScroll: [MetricTime] = []
//    var year: MetricTime?
//    
//    var body: some View {
//        VStack {
//            ForEach(monthScroll, id: \.self) { month in
//                MonthMetricView(gov: $gov, month: month)
//            }
//        }
//        .padding(.top)
//        .onAppear() {
//            populateScroll()
//        }
//    }
//    
//    private func populateScroll() {
//        let someTime = year ?? gov.finiteNotNow ?? gov.eternalNow.time
//        monthScroll = (0..<4).map { index in
//            var newTime = someTime
//            newTime.month = index
//            newTime.updateRawFromComponents()
//            return newTime
//        }
//    }
//}
//
//#Preview {
//    MonthSubScrollView(gov: .constant(Governor()))
//}
