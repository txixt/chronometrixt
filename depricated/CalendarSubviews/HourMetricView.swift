//
//  HourMetricView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 1/8/26.
//
//
//import SwiftUI
//
//struct HourMetricView: View {
//    var body: some View {
//        GeometryReader { geo in
//            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 10)) {
//                ForEach(0..<10, id: \.self) { second in
//                    ZStack {
//                        Rectangle().strokeBorder().opacity(0.1)
//                            .frame(width: .random(in: 1...88))
//                        MinuteMetricView()
//                    }
//                }
//            }
//            .frame(maxWidth: geo.size.width, maxHeight: 50)
//        }
//        .frame(width: .infinity, height: .infinity)
//    }
//}
//
//#Preview {
//    HourMetricView()
//}
