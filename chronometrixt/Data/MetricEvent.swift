//
//  MetricEvent.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/19/26.
//

import Foundation
import SwiftData

@Model final class MetricEvent {
    var id: String
    var title: String
    var notes: String
    var location: String
    var startYears: Int
    var startSeconds: Int
    var endYears: Int
    var endSeconds: Int
    var utcStart: Date
    var utcEnd: Date
    var timeZoneIdentifier: String
    var isAllDay: Bool
    var status: String // "CONFIRMED", "TENTATIVE", "CANCELLED"
    var sequence: Int
    var recurrenceRule: String // "NONE" or iCal RRULE format
    var recurringParentId: String // "NONE" if not a recurring instance
    var participantsJson: String // EventHandler will serialize/deserialize
    var alarmsJson: String // EventHandler will serialize/deserialize
    var calendarId: String
    var externalId: String // "NONE" if no external source
    var extendedProperties: String // JSON dictionary for future features, default "{}"
    
    init(id: String,
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
         status: String,
         sequence: Int,
         recurrenceRule: String,
         recurringParentId: String,
         participantsJson: String,
         alarmsJson: String,
         calendarId: String,
         externalId: String,
         extendedProperties: String = "{}"
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.location = location
        self.startYears = startYears
        self.startSeconds = startSeconds
        self.endYears = endYears
        self.endSeconds = endSeconds
        self.utcStart = utcStart
        self.utcEnd = utcEnd
        self.timeZoneIdentifier = timeZoneIdentifier
        self.isAllDay = isAllDay
        self.status = status
        self.sequence = sequence
        self.recurrenceRule = recurrenceRule
        self.recurringParentId = recurringParentId
        self.participantsJson = participantsJson
        self.alarmsJson = alarmsJson
        self.calendarId = calendarId
        self.externalId = externalId
        self.extendedProperties = extendedProperties
    }
}
