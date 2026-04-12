//
//  DayBasicView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/12/26.
//

import SwiftUI

struct DayBasicView: View {
    @Bindable var gov: Governor
    var day: MetrixtTime
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                
                HStack(spacing: 0) {
                    Text(day.yearTxt + "." + day.mwdTxt)
                        .font(.largeTitle).bold()
                        .foregroundColor(day.year == gov.eternalNow.time.year && day.mwd == gov.eternalNow.time.mwd ? .metricOrange : .primary)
                    Spacer()
                }
                
                Divider()
                
                VStack {
                    ForEach(0...9, id: \.self) { hour in
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 11)
                                .frame(width: geo.size.width * 0.9, height: 22)
                                .foregroundColor(.gray).opacity(0.2)
                            
                            HStack {
                                Text("\(hour)")
                                    .bold()
                                
                                Spacer()
                                
                                ForEach(0...9, id: \.self) { minutes in
                                    Text(":\(minutes)0")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                            }
                            
                        }
                    }
                }
            }
            .padding(.horizontal)
            .frame(width: geo.size.width, height: geo.size.width)
        }
    }
}

#Preview {
    DayBasicView(gov: Governor(), day: MetrixtTime(date: nil))
}
