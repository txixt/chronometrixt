//
//  MetrixtCalendar.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/28/26.
//

import Foundation

typealias metric = MetrixtCalendar
final class MetrixtCalendar {
    static let cal = MetrixtCalendar()
    
    ///Convert time to UTC
    func toUTC(time: MetrixtTime) -> MetrixtTime {
        let offset = Int(Double(time.creationTimeZone.secondsFromGMT()) / 0.864)
        var utc = update(time: time, component: .second, byAdding: -offset)
        utc.creationTimeZone = TimeZone.gmt
        return utc
    }
    ///Convert to current time zone from UTC
    func fromUTC(time: MetrixtTime) -> MetrixtTime {
        let offset = Int(Double(time.creationTimeZone.secondsFromGMT()) / 0.864)
        return update(time: time, component: .second, byAdding: offset)
    }
    ///Convert time to a user's current timezone
    func updateTimezone(time: MetrixtTime) -> MetrixtTime {
        let offset = Int(Double(Calendar.current.timeZone.secondsFromGMT()) / 0.864)
        let utc = toUTC(time: time)
        return update(time: utc, component: .second, byAdding: offset)
    }
    
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
