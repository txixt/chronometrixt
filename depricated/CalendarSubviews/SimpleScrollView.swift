//
//  SimpleScrollView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 1/11/26.
//
//import SwiftUI
//
//struct SimpleInfiniteScrollExample: View {
//    @Binding var gov: Governor
//    @State private var currentYearOffset: Int = 0
//    @State var yearScroll: [MetrixtTime] = []
//    
//    private var drag: some Gesture {
//        DragGesture()
//            .onEnded { value in
//                guard value.startLocation.y != value.predictedEndLocation.y else { return }
//                withAnimation(.easeInOut) {
//                    gov.finiteNotNow = yearScroll[value.startLocation.y < value.predictedEndLocation.y ? 1 : 3]
//                    if gov.finiteNotNow!.year == gov.eternalNow.time.year {
//                        gov.finiteNotNow = nil
//                    }
////                    populateScroll()
//                }
//            }
//    }
//    
//    var body: some View {
//        var someTime: MetrixtTime { gov.finiteNotNow ?? gov.eternalNow.time }
//        
//        GeometryReader { geo in
//            LazyVStack {
//                ForEach(yearScroll, id: \.year) { date in
//                    YearMetricView(gov: $gov, year: date)
//                        .opacity(someTime.year == date.year ? 1.0 : 0.5)
//                }
//                .frame(height: geo.size.height * 0.8)
//            }
//            .gesture(drag)
//        }
////        .onAppear() {
////            populateScroll()
////        }
//    }
    
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
}

#Preview() {
    SimpleInfiniteScrollExample(gov: .constant(Governor()))
}


