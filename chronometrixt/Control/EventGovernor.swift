//
//  EventGovernor.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/17/26.
//

import Foundation
import SwiftUI

@Observable final class EventGovernor {
    var id: String
    var title: String
    var notes: String
    var location: String
    var metricStart: MetrixtTime 
    var metricEnd: MetrixtTime
    var gregStart: Date
    var gregEnd: Date
    var isAllDay: Bool
    var status: EventStatus
    var sequence: Int
    var recurrence: RecurrenceRule
    var parent: String?
    var participants: [EventParticipant]
    var alarms: [EventAlarm]
    var calendar: String
    var externalId: String
    
    var editField: EditingFields = .none
    enum EditingFields { case none, title, startDateMetric, startDateGreg, endDateMetric, endDateGreg, alarms, recurrence, location, notes, calendar, participants }
    
    // MARK: - Metric Date Picker Ranges
    
    /// Weeks in a given month: months 0-2 have 10 weeks (0-9), month 3 has 6 (0-5)
    func maxWeek(forMonth month: Int) -> Int {
        month < 3 ? 9 : 5
    }
    
    /// Days in a given week: normally 0-9, except month 3 week 5 is the partial stub
    func maxDay(forMonth month: Int, week: Int, year: Int) -> Int {
        if month == 3 && week == 5 {
            return metric.cal.isLeapYear(year) ? 4 : 3
        }
        return 9
    }
    
    // MARK: - Start/End Sync
    
    /// After changing a metric start component, rebuild metricStart and sync gregStart
    func updateMetricStart(year: Int, month: Int, week: Int, day: Int, hour: Int, minute: Int, second: Int) {
        let secs = month * 10_000_000 + week * 1_000_000 + day * 100_000 + hour * 10_000 + minute * 100 + second
        metricStart = MetrixtTime(years: year, seconds: secs)
        gregStart = metricStart.toGreg()
    }
    
    /// After changing a metric end component, rebuild metricEnd and sync gregEnd
    func updateMetricEnd(year: Int, month: Int, week: Int, day: Int, hour: Int, minute: Int, second: Int) {
        let secs = month * 10_000_000 + week * 1_000_000 + day * 100_000 + hour * 10_000 + minute * 100 + second
        metricEnd = MetrixtTime(years: year, seconds: secs)
        gregEnd = metricEnd.toGreg()
    }
    
    /// After changing gregStart via DatePicker, rebuild metricStart
    func syncStartFromGreg() {
        metricStart = MetrixtTime(date: gregStart)
    }
    
    /// After changing gregEnd via DatePicker, rebuild metricEnd
    func syncEndFromGreg() {
        metricEnd = MetrixtTime(date: gregEnd)
    }
    
    init(title: String, starting: MetrixtTime, ending: MetrixtTime?) {
        self.id = ""
        self.title = title
        self.notes = ""
        self.location = ""
        self.metricStart = starting
        self.metricEnd = ending ?? metric.cal.update(time: starting, component: .second, byAdding: 2)
        self.gregStart = starting.toGreg()
        self.gregEnd = ending?.toGreg() ?? metric.cal.update(time: starting, component: .second, byAdding: 2).toGreg()
        self.isAllDay = false
        self.status = .confirmed
        self.sequence = 0
        self.recurrence = RecurrenceRule.none
        self.parent = ""
        self.participants = []
        self.alarms = []
        self.calendar = "mextrixt"
        self.externalId = ""
    }
    
    init(
        id: String,
        title: String,
        notes: String,
        location: String,
        startYears: Int,
        startSeconds: Int,
        endYears: Int,
        endSeconds: Int,
        utcStart: Date,
        utcEnd: Date,
        timeZoneIdentifier: String,
        isAllDay: Bool,
        status: EventStatus,
        sequence: Int,
        recurrenceRule: RecurrenceRule,
        recurringParentId: String,
        participants: [EventParticipant],
        alarms: [EventAlarm],
        calendarId: String,
        externalId: String,
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.location = location
        self.metricStart = UTCConverter.fromUTC(utcStart, timeZoneIdentifier: timeZoneIdentifier)
        self.metricEnd = UTCConverter.fromUTC(utcEnd, timeZoneIdentifier: timeZoneIdentifier)
        self.gregStart = UTCConverter.fromUTC(utcStart, timeZoneIdentifier: timeZoneIdentifier).toGreg()
        self.gregEnd = UTCConverter.fromUTC(utcEnd, timeZoneIdentifier: timeZoneIdentifier).toGreg()
        self.isAllDay = isAllDay
        self.status = status
        self.sequence = sequence
        self.recurrence = recurrenceRule
        self.parent = recurringParentId
        self.participants = participants
        self.alarms = alarms
        self.calendar = calendarId
        self.externalId = externalId
    }
    
    func itsADate(handler: EventHandler, gov: Governor) {
        do {
            let freshEvent = try handler.createEvent(
                title: title,
                startTime: metricStart,
                endTime: metricEnd,
                notes: notes,
                location: location,
                isAllDay: isAllDay,
                status: status,
                sequnece: sequence,
                participants: participants,
                recurrenceRule: recurrence,
                calendarId: calendar)
            gov.event = freshEvent
            gov.sheet = .showEvent
        } catch let error as EventHandler.EventError {
            switch error {
            case .eventNotFound:
                gov.errorMessage = "social 404: event not found"
                gov.alert = .error
            case .invalidJSON:
                gov.errorMessage = "invalid data format"
                gov.alert = .error
            case .invalidTimeRange:
                gov.errorMessage = "end time must be after start time"
                gov.alert = .error
            case .invalidTitle:
                gov.errorMessage = "event needs a title"
                gov.alert = .error
            }
        } catch {
            gov.errorMessage = "unexpected error: \(error.localizedDescription)"
            gov.alert = .error
        }
    }
}
