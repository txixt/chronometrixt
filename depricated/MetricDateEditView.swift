//
//  MetricDateEditView.swift
//  chronometrixt
//
//  Created by Becket on 3/18/26.
//

import SwiftUI

struct MetricDateEditView: View {
    @Binding var gov: Governor
    @Binding var eventGov: EventGovernor
    @Binding var metricDate: MetrixtTime
    
    var body: some View {
        Text("yo")
        
    }
}

//#Preview {
//    @Previewable @State var someTime = time
//    var time: MetrixtTime = MetrixtTime(date: Date(timeIntervalSince1970: TimeInterval(10.0)))
//    @Previewable @State var eventGov: EventGovernor = EventGovernor(title: "yoMama", starting: time, ending: time)
//    MetricDateEditView(gov: .constant(Governor()), eventGov: $eventGov, metricDate: .constant(someTime))
//}
