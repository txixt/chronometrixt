//
//  Governor.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/30/25.
//

import Foundation
import SwiftUI

@Observable final class Governor {
    var eternalNow: MetrixtEntropy
    var finiteNotNow: MetrixtTime? = nil
    var someTimes: [MetrixtTime] = []
    var event: MetricEvent?
    var span: ClosedRange<Int>? = nil
    var scale: CalendarScale = .year
    var sheet: SheetView? = nil
    var alert: AlertView? = nil
    var errorMessage: String = ""
    var geoSize: CGSize? = nil
    enum CalendarScale { case eon, year, month, week, day }
    enum SheetView: Identifiable { var id: Self { self }; case makeEvent, editEvent, showEvent, findEvent, timers, settings }
    enum AlertView: Identifiable { var id: Self { self }; case error, destroyEvent, destroyAllEvents }

    init() {
        eternalNow = MetrixtEntropy()
    }
    
    func populateTimes() {
        ///reset anchor to start of week to avoid truncated calendar weeks and days if the start day is > 4 or 5
//        let thisTime = finiteNotNow ?? eternalNow.time
//        let anchor = metric.cal.update(time: thisTime, component: .day, byAdding: -(thisTime.day))
        ///UNRESOLVED BUG ISSUE WITH WEEK NOT HAVING A 36 IF CURRENT DAY > 4/5  (EG. NO TARGET DAY IN THAT WEEK) or something else...
        ///this doesn't work:
//        if scale == .month {
//        anchor = metric.cal.update(time: anchor, component: .day, byAdding: -(anchor.day))
//        print("adjusted anchor to: \(anchor.fullDateTxt)")
//    }
        
        let anchor = finiteNotNow ?? eternalNow.time
        var newTimes: [MetrixtTime] = []
        

        switch scale {
        case .eon: for i in -1...1 { newTimes.append(metric.cal.update(time: anchor, component: .year, byAdding: i * 100)) }
        case .year: for i in -1...1 { newTimes.append(metric.cal.update(time: anchor, component: .year, byAdding: i)) }
        case .month: for i in -1...1 { newTimes.append(metric.cal.update(time: anchor, component: .month, byAdding: i)) }
        case .week: for i in -1...1 { newTimes.append(metric.cal.update(time: anchor, component: .week, byAdding: i)) }
        case .day: for i in -1...1 { newTimes.append(metric.cal.update(time: anchor, component: .day, byAdding: i)) }
        }
        
        someTimes = newTimes
        setSpan()
    }
    
    private func setSpan() {
        let anchor = finiteNotNow ?? eternalNow.time
        let leapYearSeconds: Int = metric.cal.isLeapYear(anchor.year) ? 36_500_000 : 36_400_000
        
        switch scale {
        case .eon: span = (anchor.year - 50)...(anchor.year + 49)
        case .year: span = anchor.year...(anchor.year + 1)
        case .month: span = (anchor.month * 10_000_000)...min(((anchor.month + 1) * 10_000_000), leapYearSeconds)
        case .week: span = ((anchor.mwd / 10) * 1_000_000)...min((((anchor.mwd / 10) + 1) * 1_000_000), leapYearSeconds)
        case .day: span = (anchor.mwd * 100_000)...((anchor.mwd + 1) * 100_000)
        }
    }
}

//    private func update() {
//        if finiteNotNow != nil { populateTimes(); setSpan() }
//    }

//@Observable final class MetricEntropy {
//    var time: MetricTime
//    var escapement: Timer?
//    var alarms: [Double] = []
//    var alert: Bool = false
//    
//    init() {
//        time = MetricTime(date: nil)
//        escapement = Timer.scheduledTimer(withTimeInterval: 0.864, repeats: true) { escapment in
//            self.updateTime()
//            RunLoop.main.add(escapment, forMode: .common)
//        }
//    }
//    
//    func setTime() {
//        time = MetricTime(date: nil)
//    }
//    
//    func updateTime() {
//        time.raw += 1
//        time.second += 1
//        if time.second > 99 {
//            time.second = 0
//            time.minute += 1
//        }
//        if time.minute > 99 {
//            time = MetricTime(date: nil)
//        }
//        if !alarms.isEmpty {
//            for alarm in alarms {
//                if time.raw == alarm {
//                    alert = true
//                }
//            }
//        }
//    }
//    
//    func killTimer() {
//        escapement = nil
//    }
//}
//
//struct MetricTime: Hashable {
//    var id: String
//    var raw: Double
//    var year: Int
//    var month: Int
//    var week: Int
//    var day: Int
//    var hour: Int
//    var minute: Int
//    var second: Int
//    var yearDays: Int
//    var daySeconds: Int
//    
//    init(date: Date?) {
//        self.id = UUID().uuidString
//        let someNow = date ?? Date.now
//        let cal = Calendar(identifier: .gregorian)
//        yearDays = cal.component(.dayOfYear, from: someNow) - 1 ///(everything in metric time should be zero index; .dayOfYear is 1 index, hence the - 1)
//        daySeconds = Int(Double((cal.component(.hour, from: someNow) * 3600) + (cal.component(.minute, from: someNow) * 60)  + cal.component(.second, from: someNow)) / 0.864)
//        year = cal.component(.year, from: someNow) + 3030
//        month = yearDays / 100
//        week = (yearDays / 10) % 10
//        day = yearDays % 10
//        hour = daySeconds / 10_000
//        minute = (daySeconds / 100) % 100
//        second = daySeconds % 100
//        raw = Double(year * 100_000_000 + yearDays * 100_000 + daySeconds)
//    }
//    
//    public func toGregorian() -> Date {
//        let cal = Calendar(identifier: .gregorian)
//        let dateYear = cal.date(bySetting: .year, value: (year - 5000), of: Date.init(timeIntervalSince1970: 0))!
//        let dateDay = cal.date(byAdding: .day, value: (yearDays), to: dateYear)!
//        return cal.date(byAdding: .second, value: Int(Double(daySeconds) * 0.864), to: dateDay)!
//    }
//    
//    public mutating func updateRawFromComponents() {
//        daySeconds = second + (minute * 100) + (hour * 10_000)
//        yearDays = (day * 100_000) + (week * 1_000_000) + (month * 10_000_000)
//        raw = Double(daySeconds + yearDays + (year * 100_000_000))
//    }
//    
//    public func isLeapYear() -> Bool {
//        let y = year - 2
//        return (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0)
//    }
//}
//extension MetricTime: CustomStringConvertible {
//    var yearText: String { return String(format: "%04d", year) }
//    var monthText: String { return String(format: "%01d", month) }
//    var weekText: String { return String(format: "%01d", week) }
//    var dayText: String { return String(format: "%01d", day) }
//    var mwdText: String { return monthText + ":" + weekText + ":" + dayText}
//    var hourText: String { return String(format: "%01d", hour) }
//    var minuteText: String { return String(format: "%02d", minute) }
//    var secondText: String { return String(format: "%02d", second) }
//    var hmsText: String { hourText + ":" + minuteText + ":" + secondText }
//    var rawText: String { return String(raw) }
//    var description: String { return yearText + "•" + mwdText + "•" + hmsText }
//}
