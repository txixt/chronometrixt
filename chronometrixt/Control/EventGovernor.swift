//
//  EventGovernor.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/17/26.
//

import Foundation
import SwiftUI
import SwiftData

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
    var calendarColor: String
    var externalId: String
    
    var editField: EditingFields = .none
    enum EditingFields { case none, title, startDateMetric, startDateGreg, endDateMetric, endDateGreg, alarms, recurrence, location, notes, calendar, participants }
    
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
        self.calendarColor = "#015659"
        self.externalId = ""
    }
    
    init(event: MetricEvent, context: ModelContext) {
        let handler = EventHandler(modelContext: context)
        self.id = event.id
        self.title = event.title
        self.notes = event.notes
        self.location = event.location
        self.metricStart = MetrixtTime(years: event.startYears, seconds: event.startSeconds)
        self.metricEnd = MetrixtTime(years: event.endYears, seconds: event.endSeconds)
        self.gregStart = MetrixtTime(years: event.startYears, seconds: event.startSeconds).toGreg()
        self.gregEnd = MetrixtTime(years: event.endYears, seconds: event.endSeconds).toGreg()
        self.isAllDay = event.isAllDay
        self.status = .confirmed
        self.sequence = event.sequence
        self.recurrence = handler.recurrenceRule(for: event)
        self.parent = event.recurringParentId
        self.participants = handler.participants(for: event)
        self.alarms = handler.alarms(for: event)
        self.calendar = event.calendarId
        self.calendarColor = event.calendarColor
        self.externalId = event.externalId
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
        calendarColor: String,
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
        self.calendarColor = calendarColor
        self.externalId = externalId
    }
    
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
struct PreviewEG {
    let metric = MetrixtTime(date: Date.now)
    let laterMetric = MetrixtCalendar().update(time: MetrixtTime(date: Date.now), component: .minute, byAdding: 1)
    
    func eg () -> EventGovernor {
        return EventGovernor(
            id: UUID().uuidString,
            title: "some event thing",
            notes: "my aunt once took me to disney land and we had a threesome with goofy.",
            location: "LAX",
            startYears: metric.years,
            startSeconds: metric.seconds,
            endYears: laterMetric.years,
            endSeconds: laterMetric.seconds,
            utcStart: metric.toGreg(),
            utcEnd: laterMetric.toGreg(),
            timeZoneIdentifier: Calendar.current.timeZone.identifier,
            isAllDay: true,
            status: EventStatus.confirmed,
            sequence: 0,
            recurrenceRule: RecurrenceRule(frequency: .metricWeekly, interval: 10),
            recurringParentId: "",
            participants: [EventParticipant(id: UUID().uuidString, name: "Becket", email: "b@txixt.com", role: .organizer, status: .declined)],
            alarms: [ EventAlarm(id: UUID().uuidString, offset: 100, type: .notification) ],
            calendarId: "metrixt",
            calendarColor: "00827C",
            externalId: ""
        )
    }
}
