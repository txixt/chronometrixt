////
////  YearScrollView.swift
////  chronometrixt
////
////  Created by Becket Bowes on 1/12/26.
////
//
//import SwiftUI
//
//struct YearScrollView: View {
//    @Binding var gov: Governor
//    @State var yearScroll: [MetricTime] = []
//    
//    var body: some View {
//        let someTime = gov.finiteNotNow ?? gov.eternalNow.time
//        
//        GeometryReader { geo in
//            ScrollView {
//                
//            }
//            LazyVStack {
//                if !yearScroll.isEmpty {
//                    ForEach(yearScroll, id: \.self) { year in
//                        YearMetricView(gov: $gov, year: year)
//                            .opacity(someTime.year == year.year ? 1.0 : 0.5)
//                            .frame(height: geo.size.height)
//                    }
//                }
//            }
//            .gesture(drag)
//        }
//        .onAppear() {
//            populateScroll()
//        }
//    }
//    
//    private func populateScroll() {
//        yearScroll = {
//            (-2...2).map { offset in
//                var newYear = gov.finiteNotNow ?? gov.eternalNow.time
//                newYear.year += offset
//                newYear.updateRawFromComponents()
//                return newYear
//            }
//        }()
//    }
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
//                    populateScroll()
//                }
//            }
//    }
//}
//
//#Preview {
//    YearScrollView(gov: .constant(Governor()))
//}
