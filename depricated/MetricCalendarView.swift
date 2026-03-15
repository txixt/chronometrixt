//
//  MetricCalendarView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/31/25.
//
//
//import SwiftUI
//struct MetricCalendarView: View {
//    @Binding var gov: Governor
//    
//    var body: some View {
//        switch gov.scale {
//        case .eon:
//            YearScrollView(gov: $gov)
//        case .year:
//            YearScrollView(gov: $gov)
//        case .month:
//            MonthScrollView(gov: $gov)
//        case .week:
//            WeekScrollView(gov: $gov)
//        case .day:
//            DayScrollView(gov: $gov)
//        }
//    }
//}
//
//#Preview {
//    MetricCalendarView(gov: .constant(Governor()))
//}
