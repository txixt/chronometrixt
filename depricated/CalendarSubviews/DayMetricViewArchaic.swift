//
//  DayMetricView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 1/8/26.
//

//import SwiftUI
//
//struct DayMetricView: View {
//    @Binding var gov: Governor
//    var day: MetricTime?
//    
//    var body: some View {
//        let time = day ?? gov.eternalNow.time
//        GeometryReader { geo in
//            
//            VStack(alignment: .leading) {
//                Text(time.yearText + "•" + time.mwdText).monospaced().bold()
//                    
//                
//                LazyHGrid(rows: Array(repeating: GridItem(.flexible(), spacing: 0), count: 10)) {
//                    ForEach(0..<10, id: \.self) { hour in
//                        HStack {
//                            Text("\(hour):00" ).monospaced().bold()
//                                .font(.system(size: 10))
//                            ZStack {
//                                HourMetricView()
//                                Rectangle().strokeBorder().opacity(0.1)
//                                    .frame(width: .random(in: 1...(geo.size.width / 10)))
//                            }
//                            .frame(width: geo.size.width * 0.8)
//                        }
//                    }
//                }
//                
//            }
//            .frame(width: geo.size.width, height: geo.size.width)
//            
//        }
//    }
//}
//
//#Preview {
//    DayMetricView(gov: .constant(Governor()))
//}
