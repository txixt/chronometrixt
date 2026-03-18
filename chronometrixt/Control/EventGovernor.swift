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
    
    var editField: EditingFields = .title
    enum EditingFields { case none, title, startDateMetric, startDateGreg, endDateMetric, endDateGreg, alarms, recurrence, location, notes, calendar, participants }
    var editTitle: Bool = false
    
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
