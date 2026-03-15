//
//  SimpleScrollView_Alternative.swift
//  chronometrixt
//
//  Created by Becket Bowes on 1/11/26.
////
import SwiftUI

//struct SimpleScrollViewAlternative: View {
//    @Binding var gov: Governor
//    @State private var currentYearOffset: Int = 0
//    
//    var body: some View {
//        ScrollView(.vertical) {
//            LazyVStack(spacing: 0) {
//                ForEach(-100...100, id: \.self) { offset in
//                    let year = yearFor(offset: offset)
//                    MetricYearView(gov: $gov, year: year)
//                        .containerRelativeFrame(.vertical)
//                        .id(offset)
//                }
//            }
//            .scrollTargetLayout()
//        }
//        .scrollPosition(id: $currentYearOffset)
//        .scrollTargetBehavior(.paging)
//        .onAppear {
//            // Start at year 0 (current time)
//            currentYearOffset = 0
//        }
//    }
//    
//    private func yearFor(offset: Int) -> MetricTime {
//        var year = gov.eternalNow.time
//        year.raw += Double(offset * 100_000_000)
//        year.year += offset
//        return year
//    }
//}
//
//#Preview() {
//    SimpleScrollViewAlternative(gov: .constant(Governor()))
//}
