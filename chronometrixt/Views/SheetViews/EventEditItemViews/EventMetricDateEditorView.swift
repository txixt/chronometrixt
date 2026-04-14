//
//  MetricDateEditorView.swift
//  chronometrixt
//
//  Created by Becket on 3/19/26.
//

import SwiftUI

struct EventMetricDateEditorView: View {
    @Bindable var gov: Governor
    @Bindable var eg: EventGovernor
    var target: EventGovernor.EditingFields
    
    var body: some View {
        VStack {
            MetrixtSubdivider()
            
            HStack {
                Text("adjust metric start time:")
                    .font(.caption)
                Spacer()
            }
            .padding(.bottom)
            
            MetricDateSteppers(gov: gov, eg: eg, target: target)
            
            SubmitButtonView(imageString: "checkmark", text: "adjusted", action: { eg.editField = .none })
                .padding(.bottom)
            
            MetrixtSubdivider()
        }
        .monospaced()
    }
    
    private func setTime(isStart: Bool, time: MetrixtTime, component: MetrixtCalendar.Component, value: Int) {
        eg.metricStart = metric.cal.replace(time: time, component: .minute, with: value)
        eg.gregStart = eg.metricStart.toGreg()
        eg.enforceEntropy()
    }
}

#Preview {
    let gov = Governor()
    let eg = PreviewEG().eg()
    EventMetricDateEditorView(
        gov: gov,
        eg: eg,
        target: .startDateMetric
    )
}
