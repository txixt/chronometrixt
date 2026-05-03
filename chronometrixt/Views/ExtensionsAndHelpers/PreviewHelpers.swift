//
//  PreviewHelpers.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/24/26.
//

import Foundation


let dummyMetricEvents: [MetricEvent] = {
    let now = MetrixtTime(date: nil)
    
    return [
        MetricEvent(
            id: "dummy-1",
            title: "Morning Meeting",
            notes: "Discuss project updates",
            location: "Conference Room A",
            startYears: now.year,
            startSeconds: (now.mwd * 100_000) + 20000,
            endYears: now.year,
            endSeconds: (now.mwd * 100_000) + 35000,
            utcStart: Date(),
            utcEnd: Date().addingTimeInterval(3600),
            timeZoneIdentifier: TimeZone.current.identifier,
            isAllDay: false,
            status: "CONFIRMED",
            sequence: 0,
            recurrenceRule: "NONE",
            recurringParentId: "NONE",
            participantsJson: "[]",
            alarmsJson: "[]",
            calendarId: "mextrixt",
            calendarColor: "#015659",
            externalId: "NONE"
        ),
        MetricEvent(
            id: "dummy-2",
            title: "Lunch Break",
            notes: "",
            location: "Cafeteria",
            startYears: now.year,
            startSeconds: (now.mwd * 100_000) + 50000,
            endYears: now.year,
            endSeconds: (now.mwd * 100_000) + 59999,   
            utcStart: Date().addingTimeInterval(7200),
            utcEnd: Date().addingTimeInterval(10800),
            timeZoneIdentifier: TimeZone.current.identifier,
            isAllDay: false,
            status: "CONFIRMED",
            sequence: 0,
            recurrenceRule: "NONE",
            recurringParentId: "NONE",
            participantsJson: "[]",
            alarmsJson: "[]",
            calendarId: "mextrixt",
            calendarColor: "#FF6B35",
            externalId: "NONE"
        ),
        MetricEvent(
            id: "dummy-3",
            title: "Team Sync",
            notes: "Weekly team standup",
            location: "Remote",
            startYears: now.year,
            startSeconds: (now.mwd * 100_000) + 75000,  // 7:50:00
            endYears: now.year,
            endSeconds: (now.mwd * 100_000) + 80000,    // 8:00:00
            utcStart: Date().addingTimeInterval(14400),
            utcEnd: Date().addingTimeInterval(16200),
            timeZoneIdentifier: TimeZone.current.identifier,
            isAllDay: false,
            status: "CONFIRMED",
            sequence: 0,
            recurrenceRule: "NONE",
            recurringParentId: "NONE",
            participantsJson: "[]",
            alarmsJson: "[]",
            calendarId: "work",
            calendarColor: "#4ECDC4",
            externalId: "NONE"
        ),
        MetricEvent(
            id: "dummy-4",
            title: "All Day Event",
            notes: "Company retreat",
            location: "Mountain Resort",
            startYears: now.year,
            startSeconds: now.mwd * 100_000,            // Start of day
            endYears: now.year,
            endSeconds: (now.mwd * 100_000) + 99_999,   // End of day (last second)
            utcStart: Date(),
            utcEnd: Date().addingTimeInterval(86400),
            timeZoneIdentifier: TimeZone.current.identifier,
            isAllDay: true,
            status: "CONFIRMED",
            sequence: 0,
            recurrenceRule: "NONE",
            recurringParentId: "NONE",
            participantsJson: "[]",
            alarmsJson: "[]",
            calendarId: "personal",
            calendarColor: "#95E1D3",
            externalId: "NONE"
        )
    ]
}()

