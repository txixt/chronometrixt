//
//  TimeControlView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 1/11/26.
//

import SwiftUI

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
                            }
                            VStack {
                                Text(gov.eternalNow.time.fullDateTxt)
                                    .bold()
                                    .foregroundColor(.metricOrange)
                                    .lineLimit(1)
                                Text(gov.eternalNow.time.toGreg().formatted())
                                    .font(.caption)
                            }
                            Spacer()
                        }
                        

                        
                        Spacer()
                    }
                    .frame(height: 120)
                    .monospaced()
                    .padding()
                }
                .padding(.horizontal)
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
    TimeControlView(gov: Governor())
}
