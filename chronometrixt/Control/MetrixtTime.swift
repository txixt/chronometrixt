//
//  MetrixtTime.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/14/26.
//

import Foundation

@Observable final class MetrixtEntropy: Equatable {
    var time: MetrixtTime
    private var escapement: Timer?
    
    init() {
        self.time = MetrixtTime(date: nil)
        escapement = Timer.scheduledTimer(withTimeInterval: 0.864, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.update()
        }
    }
    
    private func update() {
        time = time.seconds % 1000 == 0 ? MetrixtTime(date: nil) : metric.cal.update(time: time, component: .second, byAdding: 1)
    }
    
    func killTimer() { escapement?.invalidate(); escapement = nil }
    
    func restartTimer() {
        killTimer()
        time = MetrixtTime(date: nil)
        escapement = Timer.scheduledTimer(withTimeInterval: 0.864, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.update()
        }
    }
    
    deinit {
        escapement?.invalidate()
        escapement = nil
    }
    
    static func == (lhs: MetrixtEntropy, rhs: MetrixtEntropy) -> Bool {
        return lhs === rhs
    }
}

@Observable final class MetrixtAlarm: Identifiable {
    var alarm: String = UUID().uuidString
    var deadline: MetrixtTime
    var currentTime: MetrixtTime
    var escapement: Timer?
    private var onComplete: ((MetrixtTime) -> Void)?
    
    init(deadline: MetrixtTime, onComplete: ((MetrixtTime) -> Void)? = nil) {
        self.deadline = deadline
        self.currentTime = MetrixtTime(date: nil)
        self.onComplete = onComplete
        escapement = Timer.scheduledTimer(withTimeInterval: 0.864, repeats: true) { [weak self] _ in
            guard let self else { return }
            startAlarm()
        }
    }
    
    func startAlarm() {
        currentTime = currentTime.seconds % 1000 == 0 ? MetrixtTime(date: nil) : metric.cal.update(time: currentTime, component: .second, byAdding: 1)
        if currentTime.seconds >= deadline.seconds { 
            endAlarm() 
        }
    }
    
    func endAlarm() {
        escapement?.invalidate()
        escapement = nil
        onComplete?(deadline)
        //Play Musixt
    }
    
    func snooze() {
        deadline = metric.cal.update(time: deadline, component: .minute, byAdding: 10)
    }
    
    deinit {
        escapement?.invalidate()
        escapement = nil
    }
}

@Observable final class MetrixtTimer: Identifiable {
    var id: String = UUID().uuidString
    var duration: Int
    var deadline: Int
    var countdown: Int
    private var escapement: Timer?
    private var onComplete: ((Int) -> Void)?
    
    init(duration: Int) {
        self.duration = duration
        deadline = MetrixtTime(date: nil).hms + duration
        countdown = duration
        escapement = Timer.scheduledTimer(withTimeInterval: 0.864, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.updateTimer()
        }
    }
    
    private func updateTimer() {
        countdown -= 1
        if countdown <= 0 {
            escapement?.invalidate()
            escapement = nil
            //completion handler
        }
    }
    
    func cancelTimer() {
        escapement?.invalidate()
        escapement = nil
        onComplete?(deadline)
    }
    
    func toGregDeadline() -> Date {
        return Date.now.addingTimeInterval(TimeInterval(duration))
    }

    deinit {
        escapement?.invalidate()
        escapement = nil
    }
}
extension MetrixtTimer {
    var totalSeconds: Double { TimeInterval(Double(duration % 100_000) * 0.864) }
    var hours: Int { (duration / 10_000) % 10 }
    var minutes: Int { (duration / 1_000) % 100 }
    var seconds: Int { duration % 100 }
    var countdownHr: Int { (countdown / 10_000) % 10 }
    var countdownMin: Int { (countdown / 1_000) % 100 }
    var countdownSec: Int { countdown % 100 }
    var gregHr: Int { Int(totalSeconds) / 3600 }
    var gregMin: Int { (Int(totalSeconds) % 3600) / 60 }
    var gregSec: Int { Int(totalSeconds) % 60 }
}
extension MetrixtTimer: CustomStringConvertible {
    var description: String { String(duration) }
    var durationTxt: String { return String(format: "%01d:%02d:%02d", hours, minutes, seconds) }
    var countdownTxt: String { return String(format: "%01d:%02d:%02d", countdownHr, countdownMin, countdownSec)  }
    var gregDurationTxt: String { return String(format: "%02d:%02d:%02d", gregHr, gregMin, gregSec) }
}
//@Observable final class MetrixtTimer: Identifiable {
//    var id: String = UUID().uuidString
//    var deadline: MetrixtTime
//    var countdown: MetrixtTime
//    var pause: Bool = false
//    private var escapement: Timer?
//    
//    init(time: MetrixtTime) {
//        let now = MetrixtTime(date: nil)
//        deadline = metric.cal.replaceComponents(
//            time: now,
//            components: [.year, .month, .week, .day],
//            with: [now.year, now.month, now.week, (time.hms > now.hms ? now.day + 1 : now.day)]
//        )
//        countdown = metric.cal.update(time: time, component: .second, byAdding: time.seconds - now.seconds)
//        escapement = Timer.scheduledTimer(withTimeInterval: 0.864, repeats: true) { [weak self] _ in
//            guard let self else { return }
//            self.update()
//        }
//    }
//    
//    private func update() {
//        if !pause {
//            countdown = metric.cal.update(time: countdown, component: .second, byAdding: -1)
//        }
//        if countdown.seconds > deadline.seconds {
//            escapement?.invalidate()
//            escapement = nil
//        }
//    }
//    
//    deinit {
//        escapement?.invalidate()
//        escapement = nil
//    }
//}

@Observable final class MetrixtStopwatch {
    var metricMicroseconds: Int = 0
    var isStopwatching: Bool = false
    private var escapement: Timer? = nil
    
    init() {
        escapement = Timer.scheduledTimer(withTimeInterval: 0.00864, repeats: true) { [weak self] _ in
            guard let self, self.isStopwatching else { return }
            self.metricMicroseconds += 1
        }
    }
    
    func pause() {
        isStopwatching = false
    }
    
    func resume() {
        isStopwatching = true
    }
    
    func reset() {
        isStopwatching = false
        metricMicroseconds = 0
    }
    
    func killTimer() {
        escapement?.invalidate()
        escapement = nil
    }
    
    deinit {
        escapement?.invalidate()
        escapement = nil
    }
}

struct MetrixtTime: Hashable, Codable, Identifiable {
    var id: String { "\(years):\(seconds)" }
    let years: Int
    let seconds: Int
    let creationTimeZone: TimeZone = .current
    enum CodingKeys: String, CodingKey { case years, seconds }
    private static var cachedOffset: TimeInterval?     ///adjustment for DST or other local time idiosyncracies
    
    init(date: Date?) {
        years = Calendar.current.component(.year, from: date ?? .now) + 3030
        seconds = Int((Double(Calendar.current.ordinality(of: .second, in: .year, for: date ?? .now) ?? 0) - 1.0) / 0.864) //-1 for the 0index
    }
    
    init(years: Int, seconds: Int) { self.years = years; self.seconds = seconds }
    
    func toGreg() -> Date {
        guard let initialYear = Calendar.current.date(from: DateComponents(year: years - 3030)) else {
            return Date(timeIntervalSince1970: 0)
        }
        let result = initialYear.addingTimeInterval((TimeInterval(seconds) * 0.864))
        return result.addingTimeInterval(-Calendar.current.timeZone.daylightSavingTimeOffset())
//        let someOffset = MetrixtTime.cachedOffset ?? MetrixtTime.getOffset()
//        return someOffset == 0 ? result : result.addingTimeInterval(someOffset)

    }
//    private static func getOffset() -> TimeInterval {
//        cachedOffset = Date.now.timeIntervalSince(MetrixtTime(date: nil).basicGreg())
//        return cachedOffset!
//    }
//    private func basicGreg() -> Date {
//        guard let initialYear = Calendar.current.date(from: DateComponents(year: years - 3030, month: 1, day: 1)) else { return Date(timeIntervalSince1970: 0) }
//        return initialYear.addingTimeInterval(TimeInterval(seconds) * 0.864)
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


typealias metric = MetrixtCalendar
@MainActor final class MetrixtCalendar {
    static let cal = MetrixtCalendar()
    
    ///Basic replacement of components clamped to acceptable values
    func replace(time: MetrixtTime, component: Component, with value: Int) -> MetrixtTime {
        let year = component == .year ? min(value, Int.max) : time.year
        let m = (component == .month ? min(value, 3) : time.month) * 10_000_000
        let w = (component == .week ? min(value, 10) : time.week) * 1_000_000
        let d = (component == .day ? min(value, 10) : time.day) * 100_000
        let h = (component == .hour ? min(value, 10) : time.hour) * 10_000
        let mi = (component == .minute ? min(value, 100) : time.minute) * 100
        let se = (component == .second ? min(value, 100) : time.second)
        return MetrixtTime(years: year, seconds: m + w + d + h + mi + se)
    }
    enum Component { case year, month, week, day, hour, minute, second }
    
    func replaceComponents(time: MetrixtTime, components: [Component], with values: [Int]) -> MetrixtTime {
        guard components.count == values.count else { return MetrixtTime(date: nil) }
        var newTime = time
        for i in 0..<components.count {
            newTime = replace(time: newTime, component: components[i], with: values[i])
        }
        return newTime
    }
    
    ///Because of the rotational/orbital discrepancy (that a year does not divide evenly into days) we have leap years
    ///And because sidereal orbit is an annoying ~365.265363 or so days long, we have a gap in the metric calendar
    ///at the end of each year where we skip 635 or 634 (1000 -365/6) days (or 63,500,000 / 63,400,000 seconds)
    ///in what would otherwise be a normal incrementing of the number represented by YYY,YMW,DHM,iSe
    ///So this is how we deal with that. If just adding D, H, Mi, or Se, we can add the value and normalize to the year.
    ///For months and weeks we have to adjust what we add according to the different lengths of weeks and months as we do below.
    func update(time: MetrixtTime, component: Component, byAdding value: Int) -> MetrixtTime {
//        if time.mwd == 365 && component == .day && value > 0 { return MetrixtTime(years: time.year + value, seconds: time.seconds) }///this avoids problems. fucking leap years.
        let secondsToAdd: Int
        switch component {
        case .year: return addYears(to: time, value: value)
        case .week: return addWeeks(to: time, value: value)
        case .month: return addMonths(to: time, value: value)
        case .day: secondsToAdd = value * 100_000
        case .hour: secondsToAdd = value * 10_000
        case .minute: secondsToAdd = value * 100
        case .second: secondsToAdd = value
        }
        
        return normalize(years: time.years, seconds: time.seconds + secondsToAdd)
    }
    ///clamp the length of annualSeconds to the length of the target year
    private func addYears(to time: MetrixtTime, value: Int) -> MetrixtTime {
        let newYear = time.years + value
        return MetrixtTime(years: newYear, seconds: min(time.seconds, yearSeconds(newYear) - 1))
    }
    ///put remainder seconds aside, adjust the month and year to the correct positions and then multiply by the appropriate seconds and add back the remainder secons
    private func addMonths(to time: MetrixtTime, value: Int) -> MetrixtTime {
        let monthStartSeconds = time.month * 10_000_000
        let holdMyWeekAndDaySeconds = time.seconds - monthStartSeconds
        var targetYear = time.years
        var targetMonth = time.month + value
        
        while targetMonth > 3 {
            targetMonth -= 4
            targetYear += 1
        }
        while targetMonth < 0 {
            targetMonth += 4
            targetYear -= 1
        }
        
        let clampedHoldMyWeeksAndDaySeconds = min(holdMyWeekAndDaySeconds, monthSeconds(targetMonth, inYear: targetYear) - 1)
        
        return normalize(years: targetYear, seconds: (targetMonth * 10_000_000) + clampedHoldMyWeeksAndDaySeconds)
    }
    ///same as above, but evaluating for the month position as well to know the appropriate value for the given week
    private func addWeeks(to time: MetrixtTime, value: Int) -> MetrixtTime {
        let monthStartSeconds = time.month * 10_000_000
        let weekStartSeconds = time.week * 1_000_000
        let holdMyDaySeconds = time.seconds - (monthStartSeconds + weekStartSeconds)
        var targetYear = time.years
        var targetMonth = time.month
        var targetWeek = time.week + value
        
        while targetWeek >= weeksInMonth(month: targetMonth, inYear: targetYear) {
            targetWeek -= weeksInMonth(month: targetMonth, inYear: targetYear)
            targetMonth += 1
            if targetMonth > 3 {
                targetMonth = 0
                targetYear += 1
            }
        }
        while targetWeek < 0 {
            targetMonth -= 1
            if targetMonth < 0 {
                targetMonth = 3
                targetYear -= 1
            }
            targetWeek += weeksInMonth(month: targetMonth, inYear: targetYear)
        }
        
        let clampedHoldMyDaySeconds = min(holdMyDaySeconds, weekSeconds(targetWeek, inMonth: targetMonth, inYear: targetYear) - 1)
        
        return normalize(years: targetYear, seconds: (targetMonth * 10_000_000) + (targetWeek * 1_000_000) + clampedHoldMyDaySeconds)
    }
    ///If there are more or less target seconds that there are in a year, increase or decrease year and adjust the seconds accordingly
    private func normalize(years: Int, seconds: Int) -> MetrixtTime {
        var normalYears = years
        var normalSeconds = seconds
         
        while normalSeconds < 0 {
            normalYears -= 1
            normalSeconds += yearSeconds(normalYears)///evaluate the year that you're moving into.
        }
        while normalSeconds >= yearSeconds(normalYears) {
            normalSeconds -= yearSeconds(normalYears)///evaluate the year you're leaving.
            normalYears += 1
        }
        
        return MetrixtTime(years: normalYears, seconds: normalSeconds)
    }
    
    ///fucking leap years.
    private func weeksInMonth(month: Int, inYear year: Int) -> Int {
        return month != 3 ? 10 : 6
    }
    private func weekSeconds(_ week: Int, inMonth month: Int, inYear year: Int) -> Int {
        return month == 3 && week == 6 ? (isLeapYear(year) ? 500_000 : 400_000) : 1_000_000
    }
    private func monthSeconds(_ month: Int, inYear year: Int) -> Int {
        return month != 3 ? 10_000_000 : isLeapYear(year) ? 6_500_000 : 6_400_000
    }
    ///
    private func yearSeconds(_ year: Int) -> Int {
        return isLeapYear(year) ? 36_600_000 : 36_500_000
    }
    func isLeapYear(_ year: Int) -> Bool {
        let gregYear = year - 3030
        return (gregYear % 4 == 0 && gregYear % 100 != 0) || (gregYear % 400 == 0)
    }
}
