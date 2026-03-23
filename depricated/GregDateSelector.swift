//
//  GregDateSelector.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/21/26.
//

//import SwiftUI
//
//struct GregDateSelector: View {
//
//    @Binding var date: Date
//    
//    var body: some View {
//        DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
//            .datePickerStyle(.compact)
//            .tint(.primary)
//            .foregroundColor(.primary)
//            .labelsHidden()
//            .padding(.bottom)
//            .onChange(of: date) {
//                if isStart {
//                    eg.metricStart = MetrixtTime(date: eg.gregStart)
//                    enforceEntropy()
//                } else {
//                    eg.metricEnd = MetrixtTime(date: eg.gregEnd)
//                    enforceEntropy()
//                }
//            }
//    }
//}
//
//#Preview {
//    GregDateSelector(date: .constant(Date.now))
//}
