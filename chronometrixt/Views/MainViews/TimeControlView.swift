//
//  TimeControlView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 1/11/26.
//

import SwiftUI
import SwiftData

struct TimeControlView: View {
    @Bindable var gov: Governor
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                HStack {
                    Button(action: resetGov) {
                        MetricClockView(gov: gov, scale: 1.2)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Spacer()

                        if gov.finiteNotNow != nil {
                            VStack {
                                Spacer()
                                Text("then: ")
                                    .font(.footnote)
                                VStack {
                                    Text(gov.finiteNotNow!.fullDateTxt)
                                        .bold()
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    Text(gov.finiteNotNow!.toGreg().formatted())
                                        .font(.caption)
                                }
                                Spacer()
                            }
                        }
                        
                        VStack {
                            Spacer()
                            if gov.finiteNotNow != nil {
                                Text("now: ")
                                        .font(.footnote)
                                Text(gov.eternalNow.time.fullDateTxt)
                                    .bold()
                                    .foregroundColor(.metricOrange)
                                    .lineLimit(1)
                                Text(gov.eternalNow.time.toGreg().formatted())
                                    .font(.caption)
                                
                            } else {
                                Text(gov.eternalNow.time.yearTxt + "." + gov.eternalNow.time.monthWeekDayTxt)
                                    .font(.title).bold().foregroundColor(.metricOrange)
                                Text(gov.eternalNow.time.hourMinuteSecondTxt)
                                    .font(.title).bold().foregroundColor(.metricOrange)
                                Text(gov.eternalNow.time.toGreg().formatted())
                                    .bold()
                            }

                            Spacer()
                        }
                        .onTapGesture(count: 1) { resetGov() }
                        
                        Spacer()
                    }
                    .frame(height: 120)
                    .monospaced()
                    
                    Spacer()
                }
                .padding()
            }
            .glassEffect(.clear)
        }
        .padding()
    }
    
    private func resetGov() {
        gov.finiteNotNow = nil
        gov.scale = .year
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var context
    TimeControlView(gov: Governor(context: context))
}
