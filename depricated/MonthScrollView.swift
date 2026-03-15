//
////  MonthScrollView.swift
////  chronometrixt
////
////  Created by Becket Bowes on 1/12/26.
////
//
//import SwiftUI
//
//struct MonthScrollView: View {
//    @Binding var gov: Governor
//    @State var months: [MetricTime] = []
//    
//    var body: some View {
//        GeometryReader { geo in
//            
//            VStack {
//                
//                Spacer()
//                if !months.isEmpty {
//                    ForEach(0..<5) { month in
//                        MonthMetricView(gov: $gov, month: months[month])
//                            .frame(height: geo.size.height * 0.6)
//                            .padding()
//                    }
//                }
//                Spacer()
//                
//            }
//            .gesture(drag)
//            .onAppear() {
//                for i in -2..<3 {
//                    var newMonth = gov.finiteNotNow ?? gov.eternalNow.time
//                    newMonth.month += i
//                    newMonth.updateRawFromComponents()
//                    months.append(newMonth)
//                }
//            }
//        }
//    }
//    
//    private func populateScroll() {
//        months = {
//            (-2...2).map { offset in
//                var month = gov.finiteNotNow ?? gov.eternalNow.time
//                month.month += offset
//                month.updateRawFromComponents()
//                return month
//            }
//        }()
//    }
//    
//    private var drag: some Gesture {
//        DragGesture()
//            .onEnded { value in
//                guard value.startLocation.y != value.predictedEndLocation.y else { return }
//                withAnimation(.easeInOut) {
//                    gov.finiteNotNow = months[value.startLocation.y < value.predictedEndLocation.y ? 1 : 3]
//                }
//                populateScroll()
//            }
//    }
//}
//
//#Preview {
//    MonthScrollView(gov: .constant(Governor()))
//}
