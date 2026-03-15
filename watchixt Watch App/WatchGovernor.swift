//
//  WatchGovernor.swift
//  watchixt Watch App
//
//  Created by Becket Bowes on 1/4/26.
//

import Foundation
import SwiftUI

@Observable final class WatchGovernor {
    var eternalNow: MetricTime = MetricTime()
}

@Observable final class MetricTime {
    var id: String = UUID().uuidString
    var time: Int64 = 0
    
    var year: Int { Int(time / 100_000_000) }
    var mwd: Int { Int((time / 100_000) % 1_000) }
    var month: Int { Int((time / 10_000_000) % 10) }
    var week: Int { Int((time / 1_000_000) % 10) }
    var day: Int { Int((time / 100_000) % 10) }
    var hms: Int { Int(time % 100_000) }
    var hour: Int { Int((time / 10_000) % 10) }
    var minute: Int { Int((time / 100) % 100) }
    var second: Int { Int(time % 100) }
    
    private var cal = Calendar(identifier: .gregorian)
    
    func align() {
        let someNow = Date.now
        let yearComponent = Int64(cal.component(.year, from: someNow) + 3030) * 100_000_000
        let dayComponent = Int64(cal.component(.dayOfYear, from: someNow) - 1) * 100_000
        let secondComponent = Int64(Double((cal.component(.hour, from: someNow) * 3600) + 
                                         (cal.component(.minute, from: someNow) * 60) + 
                                         cal.component(.second, from: someNow)) / 0.864)
        time = yearComponent + dayComponent + secondComponent
    }
    
    func tick() {
        time += 1
        if time % 10_000 == 0 { align() }
    }
    
    public func isLeapYear(_ someYear: Int?) -> Bool {
        let y = (someYear ?? year) - 2
        return (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0)
    }
}

//init(date: Date?) {
//    self.id = UUID().uuidString
//    let someNow = date ?? Date.now
//    let cal = Calendar(identifier: .gregorian)
//    yearDays = cal.component(.dayOfYear, from: someNow) - 1 ///(everything in metric time should be zero index; .dayOfYear is 1 index, hence the - 1)
//    daySeconds = Int(Double((cal.component(.hour, from: someNow) * 3600) + (cal.component(.minute, from: someNow) * 60)  + cal.component(.second, from: someNow)) / 0.864)
//    year = cal.component(.year, from: someNow) + 3030
//    month = yearDays / 100
//    week = (yearDays / 10) % 10
//    day = yearDays % 10
//    hour = daySeconds / 10_000
//    minute = (daySeconds / 100) % 100
//    second = daySeconds % 100
//    raw = Double(year*100_000_000 + yearDays*100_000 + daySeconds)
//}

@Observable final class MetricDayEntropy {
    var id: String = UUID().uuidString
    var time: Int = 0
    var hour: Int { time / 10_000 }
    var minute: Int { (time / 100) % 100 }
    var second: Int { time % 100 }
    
    init() { align() }
    
    private var cal = Calendar(identifier: .gregorian)
    
    func align() {
        time =  Int(Double((cal.component(.hour, from: Date.now) * 3600) +
                (cal.component(.minute, from: Date.now) * 60) +
                cal.component(.second, from: Date.now)) / 0.864)
    }
    
    func tick() {
        time += 1
        if time % 1000 == 0 { align() }
    }
}







//
//@Observable final class Governor {
//    var eternalNow: MetricEntropy
//    var finiteNotNow: MetricTime?
//    var gregorian: Date
//    enum CalendarScale { case eon, year, month, week, day }
//    var calScale: CalendarScale = .year
//    
//    init() {
//        eternalNow = MetricEntropy()
//        finiteNotNow = nil
//        gregorian = Date.now
//    }
//}
//
//@Observable final class MetricEntropy {
//    var time: MetricTime
//    var escapement: Timer = Timer()
//    var alarms: [Double] = []
//    var alert: Bool = false
//    
//    init() {
//        time = MetricTime(date: nil)
//        escapement = Timer.scheduledTimer(withTimeInterval: 0.864, repeats: true) { _ in
//            self.updateTime()
//        }
//        RunLoop.main.add(escapement, forMode: .common)
//    }
//    
//    private func updateTime() {
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
//        minute = (daySeconds / 1000) % 100
//        second = daySeconds % 100
//        raw = Double(year*100_000_000 + yearDays*100_000 + daySeconds)
//    }
//    
//    public func toGregorian() -> Date {
//        let cal = Calendar(identifier: .gregorian)
//        let dateYear = cal.date(bySetting: .year, value: (year - 5000), of: Date.init(timeIntervalSince1970: 0))!
//        let dateDay = cal.date(byAdding: .day, value: (yearDays), to: dateYear)!
//        return cal.date(byAdding: .second, value: Int(Double(daySeconds) * 0.864), to: dateDay)!
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
//    var description: String { return yearText + " • " + mwdText + " • " + hmsText }
//}
//
