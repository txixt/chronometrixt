//
//  LandscapeView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/31/25.
//

import SwiftUI

struct LandscapeView: View {
    @Bindable var gov: Governor
    
    var body: some View {

        HStack {
            
            VStack {
                HStack {
                    SimpleYearView(gov: gov)
        
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    VStack {
                        Text(gov.eternalNow.time.description)
                            .font(.largeTitle).bold()
                            .lineLimit(1)
                            .foregroundColor(.metricOrange)
                            .monospaced()
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            
            Spacer()
            
            MetricClockView(gov: gov, scale: 3.0)
        }
    }
}

#Preview {
    LandscapeView(gov: Governor())
}
