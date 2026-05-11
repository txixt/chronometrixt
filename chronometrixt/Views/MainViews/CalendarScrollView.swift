//
//  CalendarScrollView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 1/13/26.
//

import SwiftUI
import SwiftData

struct CalendarScrollView: View {
    @Bindable var gov: Governor
    @State private var scrollControl: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometryReader in
            let geo = gov.geoSize ?? geometryReader.size
            LazyVStack {
                Spacer()
                HStack(alignment: .center) {
                    if gov.someTimes.count == 3 {
                        LazyVStack(spacing: 0) {
                            
                            ForEach(gov.someTimes.indices, id: \.self) { timeIndex in
                                switch gov.scale {
                                case .eon: YearMetricView(gov: gov, year: gov.someTimes[timeIndex]).opacity(timeIndex == 1 ? 1.0 : 0.2)
                                case .year:
                                    if timeIndex == 1 {
                                        YearFocusView(gov: gov, year: gov.someTimes[timeIndex])
                                    } else {
                                        YearBasicView(gov: gov, year: gov.someTimes[timeIndex]).opacity(0.2)
                                    }
                                case .month:
                                    if timeIndex == 1 {
                                        MonthFocusView(gov: gov, month: gov.someTimes[timeIndex])
                                    } else {
                                        MonthBasicView(gov: gov, month: gov.someTimes[timeIndex]).opacity(0.2)
                                    }
                                case .week:
                                    if timeIndex == 1 {
                                        WeekFocusView(gov: gov, week: gov.someTimes[timeIndex])
                                    } else {
                                        WeekBasicView(gov: gov, week: gov.someTimes[timeIndex]).opacity(0.2)
                                    }
                                case .day:
                                    if timeIndex == 1 {
                                        DayFocusView(gov: gov, day: gov.someTimes[timeIndex])
                                    } else {
                                        DayBasicView(gov: gov, day: gov.someTimes[timeIndex]).opacity(0.2)
                                    }
                                }
                            }
                            .frame(height: geo.width)
                            .clipped()
                        }
                    }
                }
                .onAppear() { gov.populateTimes() }
                .onChange(of: gov.scale) { gov.populateTimes() }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(y: -(geo.height * 0.5) + scrollControl)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let clamped = min(max(value.translation.height, -200), 200)
                        withAnimation(.spring()) {
                            scrollControl = clamped
                        }
                    }
                    .onEnded { value in
                        guard gov.someTimes.count == 3 else { return }
                        if scrollControl != 0 {
                            gov.finiteNotNow = scrollControl > 0 ? gov.someTimes[0] : gov.someTimes[2]
                            gov.populateTimes()
                        }
                        scrollControl = 0
                    }
            )
            .gesture(
                MagnifyGesture()
                    .onEnded { value in
                        if value.magnification > 1.3 {
                            switch gov.scale {
                            case .eon: gov.scale = .year
                            case .year: gov.scale = .month
                            case .month: gov.scale = .week
                            case .week: gov.scale = .day
                            case .day: break
                            }
                        }
                        if value.magnification < 0.7 {
                            switch gov.scale {
                            case .day: gov.scale = .week
                            case .week: gov.scale = .month
                            case .month: gov.scale = .year
                            case .year: gov.scale = .eon
                            case .eon: break
                            }
                        }
                    }
            )
        }
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var context
    CalendarScrollView(gov: Governor(context: context))
}


//            .onChange(of: gov.finiteNotNow) { gov.populateTimes() }
//            .onAppear() { gov.populateTimes() }
//            .frame(height: geo.size.height)
//    private func populateStack() {
//        gov.someTimes = (-1...1).map { index in
//            var newTime = gov.finiteNotNow ?? gov.eternalNow.time
//            switch gov.calScale {
//            case .eon: newTime.year += (index * 100)
//            case .year: newTime.year += index
//            case .month: newTime.month += index
//            case .week: newTime.week += index
//            case .day: newTime.day += index
//            }
//            newTime.updateRawFromComponents()
//            return newTime
//        }
//    }
//
//    private func updateTimes(add: Bool) {
//        if gov.finiteNotNow == nil { gov.finiteNotNow = gov.eternalNow.time }
//        switch gov.calScale {
//        case .eon: gov.finiteNotNow!.year += add ? 100 : -100
//        case .year, .month: gov.finiteNotNow!.year += add ? 1 : -1
//        case .week: gov.finiteNotNow!.week += add ? 1 : -1
//        case .day: gov.finiteNotNow!.day += add ? 1 : -1
//        }
//        gov.finiteNotNow?.updateRawFromComponents()
//        populateStack()
//    }
