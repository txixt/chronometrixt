//
//  MetrixtTime.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/14/26.
//

import Foundation

///CORE PRINCIPAL **DO NOT ALTER**
struct MetrixtTime: Hashable, Codable, Identifiable {
    var id: String { "\(years):\(seconds)" }
    let years: Int
    let seconds: Int
    var creationTimeZone: TimeZone = .current
    enum CodingKeys: String, CodingKey { case years, seconds }
//    private static var cachedOffset: TimeInterval?     ///adjustment for DST or other local time idiosyncracies
    
    init(date: Date?) {
        years = Calendar.current.component(.year, from: date ?? .now) + 3030
        seconds = Int((Double(Calendar.current.ordinality(of: .second, in: .year, for: date ?? .now) ?? 0) - 1.0) / 0.864) //-1 for the 0index
    }
    
    init(years: Int, seconds: Int) { self.years = years; self.seconds = seconds }
    
    func toGreg() -> Date {
        var components = DateComponents()
        components.year = years - 3030
        components.timeZone = creationTimeZone
        
        guard let initialYear = Calendar.current.date(from: components) else {
            return Date(timeIntervalSince1970: 0)
        }
        let initialDate = initialYear.addingTimeInterval(TimeInterval(seconds) * 0.864)
        let dstOffset = -Calendar.current.timeZone.daylightSavingTimeOffset(for: initialDate)
        return initialDate.addingTimeInterval(dstOffset)
    }
    
//    func toGreg() -> Date {
//        var components = DateComponents()
//        components.year = years - 3030
//        components.timeZone = creationTimeZone
//        
//        guard let initialYear = Calendar.current.date(from: components) else {
//            return Date(timeIntervalSince1970: 0)
//        }
//        
//        let initialDate = initialYear.addingTimeInterval(TimeInterval(seconds) * 0.864)
//        
//        // Get DST offset at Jan 1 (probably 0 in winter)
//        let dstAtJan1 = creationTimeZone.daylightSavingTimeOffset(for: initialYear)
//        
//        // Get DST offset at the target date (might be 3600 in summer)
//        let dstAtTarget = creationTimeZone.daylightSavingTimeOffset(for: initialDate)
//        
//        // Adjust by the DIFFERENCE
//        return initialDate.addingTimeInterval(dstAtTarget - dstAtJan1)
//    }
//    
//        guard let initialYear = Calendar.current.date(from: DateComponents(year: years - 3030)) else {
//            return Date(timeIntervalSince1970: 0)
//        }
//        let result = initialYear.addingTimeInterval((TimeInterval(seconds) * 0.864))
//        return result.addingTimeInterval(-Calendar.current.timeZone.daylightSavingTimeOffset())
    
//        var components = DateComponents()
//        components.year = years - 3030
//        components.timeZone = creationTimeZone
//        guard let initialYear = Calendar.current.date(from: components) else {
//            return Date(timeIntervalSince1970: 0)
//        }
//        let initialDate = initialYear.addingTimeInterval((TimeInterval(seconds) * 0.864))
//        let gregDate = initialDate.addingTimeInterval(-Calendar.current.timeZone.daylightSavingTimeOffset())
//        return gregDate
//

        
        ///REPLACE DST OFFSET ABOVE WITH THIS BELOW IF TESTING DEMANDS
//        let someOffset = MetrixtTime.cachedOffset ?? MetrixtTime.getOffset()
//        return someOffset == 0 ? result : result.addingTimeInterval(someOffset)

//    }
//    private static func getOffset() -> TimeInterval {
//        cachedOffset = Date.now.timeIntervalSince(MetrixtTime(date: nil).basicGreg())
//        return cachedOffset!
//    }
//    private func basicGreg() -> Date {
//        guard let initialYear = Calendar.current.date(from: DateComponents(year: years - 3030, month: 1, day: 1)) else { return Date(timeIntervalSince1970: 0) }
//        return initialYear.addingTimeInterval(TimeInterval(seconds) * 0.864)
//    }
    
        ///Moved to Calendar
//    func toUTC() -> MetrixtTime {
//        let offset = creationTimeZone.secondsFromGMT() / 0.864
//        return metric.cal.update(time: .self, component: .second, byAdding: offset)
//    }
//    func toCurrentTimeZone() {
//        let offset = Calendar.current.timeZone.secondsFromGMT() / 0.864
//        let utc = .self.toUTC()
//        return metric.cal.update(time: utc, component: .second, byAdding: offset)
//    }
}
///Computed properties are simple divisions of the seconds per year, plus rotational values for clock hands
extension MetrixtTime {
    var year: Int { years }
    var month: Int { min((seconds / 10_000_000) % 10, 3) }
    var week: Int { min((seconds / 1_000_000) % 10, 10) }
    var day: Int { min((seconds / 100_000) % 10, 10) }
    var hour: Int { min((seconds / 10_000) % 10, 10) }
    var minute: Int { min((seconds / 100) % 100, 100) }
    var second: Int { min(seconds % 100, 100) }
    var mwd: Int { min(seconds / 100_000, daysInYear()) }
    var hms: Int { min(seconds % 10_000, 100_000) }
    var metmin: Int { min((seconds / 1_000) % 10, 10) }
    var modmin: Int { min((seconds / 100) % 10, 10) }
    var metsec: Int { min((seconds / 10) % 10, 10) }
    var modsec: Int { min(seconds % 10, 10) }
    var hourHand: CGFloat { (CGFloat(seconds).truncatingRemainder(dividingBy: 100_000.0) / 100_000.0) * 360.0  }
    var minuteHand: CGFloat { (CGFloat(seconds).truncatingRemainder(dividingBy: 10_000.0) / 10_000.0) * 360.0 }
    var secondHand: CGFloat { (CGFloat(seconds).truncatingRemainder(dividingBy: 100.0) / 100.0) * 360.0 }
    
    private func daysInYear() -> Int { isLeapYear() ? 365 : 364 } //0index
    private func isLeapYear() -> Bool {
        let gregYear = years - 3030
        return (gregYear % 4 == 0 && gregYear % 100 != 0) || gregYear % 400 == 0
    }
}
extension MetrixtTime: CustomStringConvertible {
    var description: String { "\(years):\(seconds)" }
    var yearTxt: String { String(years) }
    var monthTxt: String { String(format: "%01d", month) }
    var weekTxt: String { String(format: "%01d", week) }
    var dayTxt: String { String(format: "%01d", day) }
    var hourTxt: String { String(format: "%01d", hour) }
    var minuteTxt: String { String(format: "%02d", minute) }
    var secondTxt: String { String(format: "%02d", second) }
    var mwdTxt: String { String(format: "%03d", mwd) }
    var monthWeekDayTxt: String { "\(monthTxt):\(weekTxt):\(dayTxt)" }
    var hmstxt: String { String(format: "%05d", hms) }
    var hourMinuteSecondTxt: String { "\(hourTxt):\(minuteTxt):\(secondTxt)" }
    var fullDateTxt: String { "\(yearTxt).\(monthWeekDayTxt).\(hourMinuteSecondTxt)" }
    var gregorianTimeOfDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"  // 24-hour format
        return formatter.string(from: self.toGreg())
    }
}
