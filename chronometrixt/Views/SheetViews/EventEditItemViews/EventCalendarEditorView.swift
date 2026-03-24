//
//  EventCalendarEditorView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/22/26.
//

import SwiftUI
import SwiftData

struct EventCalendarEditorView: View {
    @Query var calendars: [MetricCalendar]
    @Bindable var eg: EventGovernor
    
    var body: some View {
        VStack {
            MetrixtSubdivider()
            
            HStack {
                Text("calendar: ")
                    .font(.caption)
                Spacer()
            }
            .padding(.bottom)
            
            if !calendars.isEmpty {
                Picker("calendar", selection: $eg.calendar) {
                    ForEach(calendars) { cal in
                        Text(cal.name)
                            .tint(Color(hex: cal.colorHex))
                    }
                }
            }
            
            SubmitButtonView(imageString: "calendar", text: "calendared", action: { eg.editField = .none })
                .padding(.bottom)
            
            MetrixtSubdivider()
        }
    }
}

#Preview {
    EventCalendarEditorView(eg: PreviewEG().eg())
}
