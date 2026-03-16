//
//  CalendarScrollView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 1/13/26.
//

import SwiftUI

struct CalendarScrollView: View {
    @Bindable var gov: Governor
    @State private var scrollControl: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                HStack(alignment: .center) {
                    if gov.someTimes.count == 3 {
                        VStack(spacing: 0) {
                            
                            ForEach(gov.someTimes.indices, id: \.self) { timeIndex in
                                switch gov.scale {
                                case .eon: YearMetricView(gov: gov, year: gov.someTimes[timeIndex]).opacity(timeIndex == 1 ? 1.0 : 0.2)
                                case .year: YearMetricView(gov: gov, year: gov.someTimes[timeIndex]).opacity(timeIndex == 1 ? 1.0 : 0.2)
                                case .month: MonthMetricView(gov: gov, month: gov.someTimes[timeIndex]).opacity(timeIndex == 1 ? 1.0 : 0.2)
                                case .week: WeekMetricView(gov: gov, week: gov.someTimes[timeIndex]).opacity(timeIndex == 1 ? 1.0 : 0.2)
                                case .day: DayMetricView(gov: gov, day: gov.someTimes[timeIndex]).opacity(timeIndex == 1 ? 1.0 : 0.5)
                                }
                            }
                            .frame(height: geo.size.width)
                            .clipped()
                        }
                    }
                }
                .onAppear() { gov.populateTimes() }
                .onChange(of: gov.scale) { gov.populateTimes() }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .offset(y: -(geo.size.height * 0.5) + scrollControl)
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
    CalendarScrollView(gov: Governor())
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
