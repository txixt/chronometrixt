//
//  Item.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/30/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

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

final class UTCConverter {
    
    /// Convert a local-frame MetrixtTime to an absolute UTC Date.
    ///
    /// MetrixtTime stores local wall-clock time in metric form:
    ///   years = gregorianYear + 3030
    ///   seconds = ordinality-of-second-in-year (local) / 0.864
    ///
    /// To get UTC we reconstruct the local Date, then the Date type
    /// is already an absolute moment — no further adjustment needed,
    /// because Calendar.current interprets the components in local time
    /// and returns the correct absolute instant.
    static func toUTC(from metrixtTime: MetrixtTime) -> Date {
        let gregYear = metrixtTime.years - 3030
        let localZone = metrixtTime.creationTimeZone
        
        var cal = Calendar.current
        cal.timeZone = localZone
        
        // Reverse the fromUTC formula: metric seconds -> gregorian ordinality
        // fromUTC does: metrixtSeconds = Int((Double(ordinality) - 1.0) / 0.864)
        // Reverse:      ordinality = Int(Double(metrixtSeconds) * 0.864) + 1
        let ordinality = Int(Double(metrixtTime.seconds) * 0.864) + 1
        
        // Decompose ordinality into day-of-year and time-of-day components,
        // then reconstruct via DateComponents. This avoids the DST drift that
        // occurs with addingTimeInterval or date(byAdding: .second) approaches,
        // because ordinality counts wall-clock seconds (skipping DST gaps) while
        // addingTimeInterval counts elapsed real seconds.
        let dayOfYear = (ordinality - 1) / 86400
        let secondOfDay = (ordinality - 1) % 86400
        let hour = secondOfDay / 3600
        let minute = (secondOfDay % 3600) / 60
        let second = secondOfDay % 60
        
        guard let result = cal.date(from: DateComponents(
            calendar: cal,
            timeZone: localZone,
            year: gregYear,
            month: 1,
            day: 1 + dayOfYear,
            hour: hour,
            minute: minute,
            second: second
        )) else {
            return Date(timeIntervalSince1970: 0)
        }
        
        return result
    }
    
    /// Convert an absolute UTC Date to a local-frame MetrixtTime.
    ///
    /// Interprets the Date in Calendar.current (the user's local timezone),
    /// extracts the local year and seconds-into-year, then converts to metric.
    /// This matches how MetrixtTime.init(date:) works.
    static func fromUTC(_ utcDate: Date, timeZoneIdentifier: String) -> MetrixtTime {
        // Use the target timezone to interpret the absolute moment as local wall-clock
        let tz = TimeZone(identifier: timeZoneIdentifier) ?? .current
        var calendar = Calendar.current
        calendar.timeZone = tz
        
        let gregYear = calendar.component(.year, from: utcDate)
        let metrixtYear = gregYear + 3030
        
        // Ordinality of the second within the year, in the local timezone
        // This mirrors MetrixtTime.init(date:) which uses Calendar.current.ordinality
        guard let ordinality = calendar.ordinality(of: .second, in: .year, for: utcDate) else {
            return MetrixtTime(years: metrixtYear, seconds: 0)
        }
        
        // Convert gregorian ordinality to metric seconds (same formula as MetrixtTime.init)
        let metrixtSeconds = Int((Double(ordinality) - 1.0) / 0.864)
        
        return MetrixtTime(years: metrixtYear, seconds: metrixtSeconds)
    }
    
    /// Get the current timezone offset from UTC in seconds *for a specific date*.
    /// Uses secondsFromGMT(for:) which correctly accounts for DST at that moment.
    static func offsetFromUTC(for date: Date = .now, in timeZone: TimeZone = .current) -> Int {
        return timeZone.secondsFromGMT(for: date)
    }
}

// MARK: - Event Supporting Types

enum EventStatus: String, Codable, Sendable {
    case confirmed = "CONFIRMED"
    case tentative = "TENTATIVE"
    case cancelled = "CANCELLED"
}

struct RecurrenceRule: Codable, Sendable {
    enum Frequency: String, Codable, Sendable {
        case daily, weekly, monthly, yearly, none
    }
    
    var frequency: Frequency
    var interval: Int // every X days/weeks/months
    var count: Int? // end after X occurrences
    var until: Date? // or end on specific date
    
    static let none = RecurrenceRule(frequency: .none, interval: 1, count: nil, until: nil)
    
    /// Convert to iCal RRULE format
    func toRRULE() -> String {
        if frequency == .none { return "NONE" }
        
        var parts: [String] = []
        parts.append("FREQ=\(frequency.rawValue.uppercased())")
        
        if interval > 1 {
            parts.append("INTERVAL=\(interval)")
        }
        
        if let count = count {
            parts.append("COUNT=\(count)")
        } else if let until = until {
            let formatter = ISO8601DateFormatter()
            parts.append("UNTIL=\(formatter.string(from: until))")
        }
        
        return parts.joined(separator: ";")
    }
    
    /// Parse from iCal RRULE format
    static func fromRRULE(_ rrule: String) -> RecurrenceRule {
        if rrule == "NONE" { return .none }
        
        var frequency: Frequency = .none
        var interval = 1
        var count: Int? = nil
        var until: Date? = nil
        
        let parts = rrule.split(separator: ";")
        for part in parts {
            let keyValue = part.split(separator: "=", maxSplits: 1)
            guard keyValue.count == 2 else { continue }
            
            let key = String(keyValue[0])
            let value = String(keyValue[1])
            
            switch key {
            case "FREQ":
                frequency = Frequency(rawValue: value.lowercased()) ?? .none
            case "INTERVAL":
                interval = Int(value) ?? 1
            case "COUNT":
                count = Int(value)
            case "UNTIL":
                let formatter = ISO8601DateFormatter()
                until = formatter.date(from: value)
            default:
                break
            }
        }
        
        return RecurrenceRule(frequency: frequency, interval: interval, count: count, until: until)
    }
}

struct EventParticipant: Codable, Identifiable, Sendable {
    var id: String
    var name: String
    var email: String
    var role: Role
    var status: ParticipationStatus
    
    enum Role: String, Codable, Sendable {
        case organizer, required, optional
    }
    
    enum ParticipationStatus: String, Codable, Sendable {
        case accepted, declined, tentative, needsAction
    }
}

struct EventAlarm: Codable, Identifiable, Sendable {
    var id: String
    var offset: TimeInterval // seconds before event
    var type: AlarmType
    
    enum AlarmType: String, Codable, Sendable {
        case notification, email, sound
    }
}

// MARK: - EventHandler

@MainActor
final class EventHandler {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Create Events
    func createEvent(
        title: String,
        startTime: MetrixtTime,
        endTime: MetrixtTime? = nil,
        notes: String = "",
        location: String = "",
        isAllDay: Bool = false,
        status: EventStatus = .confirmed,
        sequnece: Int?,
        participants: [EventParticipant] = [],
        alarms: [EventAlarm] = [],
        recurrenceRule: RecurrenceRule? = nil,
        calendarId: String = "METRIXT"
    ) throws -> MetricEvent {
        // 1. Validate inputs
        guard !title.isEmpty else {
            throw EventError.invalidTitle
        }
        
        // 2. Convert MetrixtTime to UTC
        let utcStart = UTCConverter.toUTC(from: startTime)
        let finalEndTime = endTime ?? MetrixtTime(years: startTime.years, seconds: startTime.seconds + 1)
        let utcEnd = UTCConverter.toUTC(from: finalEndTime)
        
        guard utcEnd > utcStart else {
            throw EventError.invalidTimeRange
        }
        
        // 3. Serialize complex data to JSON
        let participantsJson = try encodeToJson(participants)
        let alarmsJson = try encodeToJson(alarms)
        let recurrenceString = recurrenceRule?.toRRULE() ?? "NONE"
        
        // 4. Create MetricEvent with all required fields
        let event = MetricEvent(
            id: UUID().uuidString,
            title: title,
            notes: notes,
            location: location,
            startYears: startTime.years,
            startSeconds: startTime.seconds,
            endYears: finalEndTime.years,
            endSeconds: finalEndTime.seconds,
            utcStart: utcStart,
            utcEnd: utcEnd,
            timeZoneIdentifier: startTime.creationTimeZone.identifier,
            isAllDay: isAllDay,
            status: status.rawValue,
            sequence: 0,
            recurrenceRule: recurrenceString,
            recurringParentId: "NONE",
            participantsJson: participantsJson,
            alarmsJson: alarmsJson,
            calendarId: calendarId,
            externalId: "NONE"
        )
        
        // 5. Insert into modelContext
        modelContext.insert(event)
        
        // 6. Materialize recurrence instances if a rule was provided
        if let recurrenceRule = recurrenceRule, recurrenceRule.frequency != .none {
            try materializeRecurrences(for: event)
        }
        
        return event
    }
    
    // MARK: - Encoding/Decoding Helpers
    private func encodeToJson<T: Encodable>(_ value: T) throws -> String {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        return String(data: data, encoding: .utf8) ?? "[]"
    }
    
    private func decodeFromJson<T: Decodable>(_ json: String, as type: T.Type) throws -> T {
        guard let data = json.data(using: .utf8) else {
            throw EventError.invalidJSON
        }
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    }
    
    enum EventError: Error {
        case invalidTitle
        case invalidTimeRange
        case invalidJSON
        case eventNotFound
    }
    
    // MARK: - Query Events
    func fetchEvents(forYear year: Int, inRange secondsRange: Range<Int>) -> [MetricEvent] {
        let predicate = #Predicate<MetricEvent> { event in
            event.startYears == year &&
            event.startSeconds >= secondsRange.lowerBound &&
            event.startSeconds < secondsRange.upperBound
        }
        
        let descriptor = FetchDescriptor<MetricEvent>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.startSeconds)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching events: \(error)")
            return []
        }
    }
    
    /// Fetch events around the current time (useful for showing "today" or "this week")
    func fetchRecentEvents(around time: MetrixtTime, rangeDays: Int = 1) -> [MetricEvent] {
        let secondsPerDay = 100_000
        let rangeSeconds = secondsPerDay * rangeDays
        
        let lowerBound = max(0, time.seconds - rangeSeconds)
        let upperBound = time.seconds + rangeSeconds
        
        return fetchEvents(forYear: time.years, inRange: lowerBound..<upperBound)
    }
    
    /// Fetch all events (use sparingly - prefer year/range queries)
    func fetchAllEvents() -> [MetricEvent] {
        let descriptor = FetchDescriptor<MetricEvent>(
            sortBy: [SortDescriptor(\.startYears), SortDescriptor(\.startSeconds)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching all events: \(error)")
            return []
        }
    }
    
    // MARK: - Decode Complex Properties
    func participants(for event: MetricEvent) -> [EventParticipant] {
        guard let decoded = try? decodeFromJson(event.participantsJson, as: [EventParticipant].self) else {
            return []
        }
        return decoded
    }
    
    func alarms(for event: MetricEvent) -> [EventAlarm] {
        guard let decoded = try? decodeFromJson(event.alarmsJson, as: [EventAlarm].self) else {
            return []
        }
        return decoded
    }
    
    func recurrenceRule(for event: MetricEvent) -> RecurrenceRule {
        if event.recurrenceRule == "NONE" {
            return .none
        }
        // Parse iCal RRULE format here when needed
        return RecurrenceRule.fromRRULE(event.recurrenceRule)
    }
    
    // MARK: - Update Events
    func updateEvent(
        _ event: MetricEvent,
        title: String? = nil,
        startTime: MetrixtTime? = nil,
        endTime: MetrixtTime? = nil,
        notes: String? = nil,
        location: String? = nil,
        isAllDay: Bool? = nil,
        status: EventStatus? = nil,
        participants: [EventParticipant]? = nil,
        alarms: [EventAlarm]? = nil
    ) throws {
        // Update only the provided values
        if let title = title {
            guard !title.isEmpty else { throw EventError.invalidTitle }
            event.title = title
        }
        
        if let startTime = startTime {
            event.startYears = startTime.years
            event.startSeconds = startTime.seconds
            event.utcStart = UTCConverter.toUTC(from: startTime)
        }
        
        if let endTime = endTime {
            event.endYears = endTime.years
            event.endSeconds = endTime.seconds
            event.utcEnd = UTCConverter.toUTC(from: endTime)
        }
        
        // Validate time range if either was updated
        if startTime != nil || endTime != nil {
            guard event.utcEnd > event.utcStart else {
                throw EventError.invalidTimeRange
            }
        }
        
        if let notes = notes { event.notes = notes }
        if let location = location { event.location = location }
        if let isAllDay = isAllDay { event.isAllDay = isAllDay }
        if let status = status { event.status = status.rawValue }
        
        if let participants = participants {
            event.participantsJson = try encodeToJson(participants)
        }
        
        if let alarms = alarms {
            event.alarmsJson = try encodeToJson(alarms)
        }
        
        // Increment sequence number for this update
        event.sequence += 1
    }
    
    // MARK: - Destroy Events
    
    /// Delete a single event instance (a child, or a standalone non-recurring event).
    /// For a parent with children, use destroyEventSeries instead.
    func destroySingleEvent(_ event: MetricEvent) {
        if event.recurringParentId != "NONE" || !hasRecurringChildren(event) {
            modelContext.delete(event)
        }
    }
    
    /// Delete an entire recurring series: parent + all children.
    /// Can be called with either the parent or any child in the series.
    func destroyEventSeries(_ event: MetricEvent) {
        let parentId = event.recurringParentId != "NONE" ? event.recurringParentId : event.id
        
        // Delete all children
        let childPredicate = #Predicate<MetricEvent> { e in
            e.recurringParentId == parentId
        }
        if let children = try? modelContext.fetch(FetchDescriptor<MetricEvent>(predicate: childPredicate)) {
            for child in children {
                modelContext.delete(child)
            }
        }
        
        // Delete the parent
        let parentPredicate = #Predicate<MetricEvent> { e in
            e.id == parentId
        }
        if let parents = try? modelContext.fetch(FetchDescriptor<MetricEvent>(predicate: parentPredicate)),
           let parent = parents.first {
            modelContext.delete(parent)
        }
    }
    
    /// Delete this event and all future siblings in the series.
    /// Truncates the parent's RRULE with an UNTIL before this event.
    func destroyThisAndFuture(_ event: MetricEvent) {
        guard event.recurringParentId != "NONE" else {
            // This IS the parent — deleting "this and future" from parent = delete entire series
            destroyEventSeries(event)
            return
        }
        
        let parentId = event.recurringParentId
        let cutoffStart = event.utcStart
        
        // Delete all children at or after this event's start time
        let futurePredicate = #Predicate<MetricEvent> { e in
            e.recurringParentId == parentId && e.utcStart >= cutoffStart
        }
        if let futureChildren = try? modelContext.fetch(FetchDescriptor<MetricEvent>(predicate: futurePredicate)) {
            for child in futureChildren {
                modelContext.delete(child)
            }
        }
        
        // Truncate the parent's RRULE
        let parentPredicate = #Predicate<MetricEvent> { e in
            e.id == parentId
        }
        if let parents = try? modelContext.fetch(FetchDescriptor<MetricEvent>(predicate: parentPredicate)),
           let parent = parents.first {
            var rule = RecurrenceRule.fromRRULE(parent.recurrenceRule)
            rule.until = cutoffStart.addingTimeInterval(-1)
            rule.count = nil
            parent.recurrenceRule = rule.toRRULE()
            parent.sequence += 1
        }
    }
    
    /// Check if an event has recurring children
    private func hasRecurringChildren(_ event: MetricEvent) -> Bool {
        let eventId = event.id
        let predicate = #Predicate<MetricEvent> { e in
            e.recurringParentId == eventId
        }
        let descriptor = FetchDescriptor<MetricEvent>(predicate: predicate)
        do {
            let children = try modelContext.fetch(descriptor)
            return !children.isEmpty
        } catch {
            return false
        }
    }
    
    // MARK: - Edit Propagation
    
    /// Update all events in a series: modifies the parent, deletes all children, re-materializes.
    /// Can be called with either the parent or any child.
    func updateEventSeries(
        _ event: MetricEvent,
        title: String? = nil,
        notes: String? = nil,
        location: String? = nil,
        isAllDay: Bool? = nil,
        status: EventStatus? = nil,
        participants: [EventParticipant]? = nil,
        alarms: [EventAlarm]? = nil
    ) throws {
        // Find the parent
        let parentId = event.recurringParentId != "NONE" ? event.recurringParentId : event.id
        let parentPredicate = #Predicate<MetricEvent> { e in e.id == parentId }
        guard let parents = try? modelContext.fetch(FetchDescriptor<MetricEvent>(predicate: parentPredicate)),
              let parent = parents.first else { return }
        
        // Update parent fields (not time — that would change the recurrence anchor)
        try updateEvent(parent, title: title, notes: notes, location: location,
                        isAllDay: isAllDay, status: status, participants: participants, alarms: alarms)
        
        // Delete all existing children
        let childPredicate = #Predicate<MetricEvent> { e in e.recurringParentId == parentId }
        if let children = try? modelContext.fetch(FetchDescriptor<MetricEvent>(predicate: childPredicate)) {
            for child in children { modelContext.delete(child) }
        }
        
        // Re-materialize with updated parent fields
        try materializeRecurrences(for: parent)
    }
    
    /// Update this event and all future siblings: splits the series.
    /// Truncates the old series at the cutoff, creates a new parent from the
    /// modified event, and materializes new children.
    func updateThisAndFuture(
        _ event: MetricEvent,
        title: String? = nil,
        startTime: MetrixtTime? = nil,
        endTime: MetrixtTime? = nil,
        notes: String? = nil,
        location: String? = nil,
        isAllDay: Bool? = nil,
        status: EventStatus? = nil,
        participants: [EventParticipant]? = nil,
        alarms: [EventAlarm]? = nil
    ) throws {
        guard event.recurringParentId != "NONE" else {
            // This is the parent — equivalent to "edit all"
            try updateEventSeries(event, title: title, notes: notes, location: location,
                                  isAllDay: isAllDay, status: status, participants: participants, alarms: alarms)
            return
        }
        
        let oldParentId = event.recurringParentId
        let cutoffStart = event.utcStart
        
        // 1. Find the old parent to copy its RRULE
        let parentPredicate = #Predicate<MetricEvent> { e in e.id == oldParentId }
        guard let parents = try? modelContext.fetch(FetchDescriptor<MetricEvent>(predicate: parentPredicate)),
              let oldParent = parents.first else { return }
        let originalRrule = oldParent.recurrenceRule
        
        // 2. Delete this event and all future siblings
        let futurePredicate = #Predicate<MetricEvent> { e in
            e.recurringParentId == oldParentId && e.utcStart >= cutoffStart
        }
        if let futureChildren = try? modelContext.fetch(FetchDescriptor<MetricEvent>(predicate: futurePredicate)) {
            for child in futureChildren { modelContext.delete(child) }
        }
        
        // 3. Truncate old parent's RRULE
        var truncatedRule = RecurrenceRule.fromRRULE(originalRrule)
        truncatedRule.until = cutoffStart.addingTimeInterval(-1)
        truncatedRule.count = nil
        oldParent.recurrenceRule = truncatedRule.toRRULE()
        oldParent.sequence += 1
        
        // 4. Create a new parent event with modified fields starting at the cutoff
        let newStartTime = startTime ?? UTCConverter.fromUTC(cutoffStart, timeZoneIdentifier: oldParent.timeZoneIdentifier)
        let duration = oldParent.utcEnd.timeIntervalSince(oldParent.utcStart)
        let newUtcStart = startTime != nil ? UTCConverter.toUTC(from: newStartTime) : cutoffStart
        let newEndTime = endTime ?? UTCConverter.fromUTC(newUtcStart.addingTimeInterval(duration), timeZoneIdentifier: oldParent.timeZoneIdentifier)
        let newUtcEnd = endTime != nil ? UTCConverter.toUTC(from: newEndTime) : newUtcStart.addingTimeInterval(duration)
        
        let newParent = MetricEvent(
            id: UUID().uuidString,
            title: title ?? oldParent.title,
            notes: notes ?? oldParent.notes,
            location: location ?? oldParent.location,
            startYears: newStartTime.years,
            startSeconds: newStartTime.seconds,
            endYears: newEndTime.years,
            endSeconds: newEndTime.seconds,
            utcStart: newUtcStart,
            utcEnd: newUtcEnd,
            timeZoneIdentifier: oldParent.timeZoneIdentifier,
            isAllDay: isAllDay ?? oldParent.isAllDay,
            status: status?.rawValue ?? oldParent.status,
            sequence: 0,
            recurrenceRule: originalRrule,
            recurringParentId: "NONE",
            participantsJson: participants != nil ? (try encodeToJson(participants!)) : oldParent.participantsJson,
            alarmsJson: alarms != nil ? (try encodeToJson(alarms!)) : oldParent.alarmsJson,
            calendarId: oldParent.calendarId,
            externalId: "NONE",
            extendedProperties: oldParent.extendedProperties
        )
        
        modelContext.insert(newParent)
        
        // 5. Materialize children for the new parent
        try materializeRecurrences(for: newParent)
    }
    
    // MARK: - Import/Export (delegates to EventBatchHandler off main thread)
    
    /// Import events from iCalendar (.ics) data. Parsing happens off main thread.
    func importFromICalendar(_ icalData: String) async throws -> [MetricEvent] {
        let parsed = try await EventBatchHandler.parseICalendar(icalData)
        return try insertParsedEvents(parsed)
    }
    
    /// Import events from Google Calendar JSON export. Parsing happens off main thread.
    func importFromGCalendar(_ gcalData: String) async throws -> [MetricEvent] {
        let parsed = try await EventBatchHandler.parseGCalendarJSON(gcalData)
        return try insertParsedEvents(parsed)
    }
    
    /// Export parent events to iCalendar (.ics) format string. Serialization happens off main thread.
    /// Only exports parents (which carry the RRULE); children are excluded since they
    /// will be regenerated on import from the parent's recurrence rule.
    func exportToICalendar() async -> String {
        let events = fetchParentEvents()
        let snapshots = events.map { EventBatchHandler.EventSnapshot(from: $0) }
        return await EventBatchHandler.serializeToICalendar(snapshots)
    }
    
    /// Export parent events to Google Calendar-compatible JSON. Serialization happens off main thread.
    func exportToGCalendarJSON() async -> String {
        let events = fetchParentEvents()
        let snapshots = events.map { EventBatchHandler.EventSnapshot(from: $0) }
        return await EventBatchHandler.serializeToGCalendarJSON(snapshots)
    }
    
    /// Insert parsed event data into the model context (must run on MainActor)
    private func insertParsedEvents(_ parsed: [EventBatchHandler.ParsedEvent]) throws -> [MetricEvent] {
        var created: [MetricEvent] = []
        for p in parsed {
            let event = MetricEvent(
                id: p.id,
                title: p.title,
                notes: p.notes,
                location: p.location,
                startYears: p.startYears,
                startSeconds: p.startSeconds,
                endYears: p.endYears,
                endSeconds: p.endSeconds,
                utcStart: p.utcStart,
                utcEnd: p.utcEnd,
                timeZoneIdentifier: p.timeZoneIdentifier,
                isAllDay: p.isAllDay,
                status: p.status,
                sequence: p.sequence,
                recurrenceRule: p.recurrenceRule,
                recurringParentId: "NONE",
                participantsJson: p.participantsJson,
                alarmsJson: p.alarmsJson,
                calendarId: p.calendarId,
                externalId: p.externalId,
                extendedProperties: p.extendedProperties
            )
            modelContext.insert(event)
            created.append(event)
        }
        
        // Materialize recurrences for any imported events with RRULE
        for event in created where event.recurrenceRule != "NONE" {
            try materializeRecurrences(for: event)
        }
        
        return created
    }
    
    // MARK: - Recurrence Materialization
    
    /// Generate child MetricEvent rows for each occurrence of a recurring event.
    /// Uses RecurrenceExpander to compute Gregorian dates, then converts each to metric.
    /// Deduplicates against existing children to support horizon extension.
    @discardableResult
    func materializeRecurrences(
        for parent: MetricEvent,
        horizon: Date? = nil
    ) throws -> [MetricEvent] {
        guard parent.recurrenceRule != "NONE" else { return [] }
        
        let effectiveHorizon = horizon ?? Calendar.current.date(byAdding: .year, value: 2, to: parent.utcStart)!
        
        // Get existing children's start dates for dedup
        let parentId = parent.id
        let childPredicate = #Predicate<MetricEvent> { e in
            e.recurringParentId == parentId
        }
        let existingChildren = (try? modelContext.fetch(FetchDescriptor<MetricEvent>(predicate: childPredicate))) ?? []
        let existingStarts = Set(existingChildren.map { Int($0.utcStart.timeIntervalSince1970) })
        
        // Expand recurrence in Gregorian space
        let occurrences = RecurrenceExpander.expand(
            rruleString: parent.recurrenceRule,
            utcStart: parent.utcStart,
            utcEnd: parent.utcEnd,
            timeZoneIdentifier: parent.timeZoneIdentifier,
            horizon: effectiveHorizon
        )
        
        var created: [MetricEvent] = []
        
        for occ in occurrences {
            // Dedup: skip if a child already exists at this start time (within 1 second)
            let startKey = Int(occ.utcStart.timeIntervalSince1970)
            if existingStarts.contains(startKey) { continue }
            
            let startMetrixt = UTCConverter.fromUTC(occ.utcStart, timeZoneIdentifier: parent.timeZoneIdentifier)
            let endMetrixt = UTCConverter.fromUTC(occ.utcEnd, timeZoneIdentifier: parent.timeZoneIdentifier)
            
            let child = MetricEvent(
                id: UUID().uuidString,
                title: parent.title,
                notes: parent.notes,
                location: parent.location,
                startYears: startMetrixt.years,
                startSeconds: startMetrixt.seconds,
                endYears: endMetrixt.years,
                endSeconds: endMetrixt.seconds,
                utcStart: occ.utcStart,
                utcEnd: occ.utcEnd,
                timeZoneIdentifier: parent.timeZoneIdentifier,
                isAllDay: parent.isAllDay,
                status: parent.status,
                sequence: 0,
                recurrenceRule: "NONE",
                recurringParentId: parent.id,
                participantsJson: parent.participantsJson,
                alarmsJson: parent.alarmsJson,
                calendarId: parent.calendarId,
                externalId: "NONE",
                extendedProperties: parent.extendedProperties
            )
            
            modelContext.insert(child)
            created.append(child)
        }
        
        return created
    }
    
    /// Fetch only parent events (those that are not recurring children).
    /// Used for export — children are regenerated from the parent's RRULE on import.
    func fetchParentEvents() -> [MetricEvent] {
        let predicate = #Predicate<MetricEvent> { event in
            event.recurringParentId == "NONE"
        }
        let descriptor = FetchDescriptor<MetricEvent>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.startYears), SortDescriptor(\.startSeconds)]
        )
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching parent events: \(error)")
            return []
        }
    }
    
    // MARK: - Horizon Refresh
    
    /// Extend materialization for recurring events whose last child is approaching.
    /// Call on app launch or periodically. Finds parents whose latest child is within
    /// 3 months of now and extends materialization to 2 years from now.
    /// The dedup logic in materializeRecurrences prevents duplicate children.
    func refreshMaterializationHorizons() throws {
        let now = Date.now
        let threeMonthsFromNow = Calendar.current.date(byAdding: .month, value: 3, to: now)!
        let newHorizon = Calendar.current.date(byAdding: .year, value: 2, to: now)!
        
        // Find all recurring parent events
        let noneString = "NONE"
        let predicate = #Predicate<MetricEvent> { e in
            e.recurrenceRule != noneString && e.recurringParentId == noneString
        }
        let parents = (try? modelContext.fetch(FetchDescriptor<MetricEvent>(predicate: predicate))) ?? []
        
        for parent in parents {
            // Find the latest child
            let parentId = parent.id
            let childPredicate = #Predicate<MetricEvent> { e in
                e.recurringParentId == parentId
            }
            var descriptor = FetchDescriptor<MetricEvent>(predicate: childPredicate)
            descriptor.sortBy = [SortDescriptor(\.utcStart, order: .reverse)]
            descriptor.fetchLimit = 1
            
            if let lastChild = (try? modelContext.fetch(descriptor))?.first {
                if lastChild.utcStart < threeMonthsFromNow {
                    try materializeRecurrences(for: parent, horizon: newHorizon)
                }
            }
        }
    }
    
}

// MARK: - RecurrenceExpander

/// Expands recurrence rules into concrete Gregorian occurrence dates.
/// All math happens in Gregorian space via Foundation Calendar, then each
/// occurrence is converted to MetrixtTime at the insertion site.
/// Sendable and non-isolated — safe to call from any context.
final class RecurrenceExpander: Sendable {
    
    struct OccurrenceDate: Sendable {
        let utcStart: Date
        let utcEnd: Date
    }
    
    /// Expand an RRULE string into concrete occurrence dates.
    /// - Parameters:
    ///   - rruleString: iCal RRULE format (e.g. "FREQ=WEEKLY;INTERVAL=1;COUNT=52")
    ///   - utcStart: The parent event's absolute start date (anchor)
    ///   - utcEnd: The parent event's absolute end date (used to compute duration)
    ///   - timeZoneIdentifier: Timezone the event was created in
    ///   - horizon: Maximum date to generate occurrences until
    /// - Returns: Occurrence dates excluding the parent's own date
    static func expand(
        rruleString: String,
        utcStart: Date,
        utcEnd: Date,
        timeZoneIdentifier: String,
        horizon: Date
    ) -> [OccurrenceDate] {
        let rule = RecurrenceRule.fromRRULE(rruleString)
        guard rule.frequency != .none else { return [] }
        
        let duration = utcEnd.timeIntervalSince(utcStart)
        
        // Work in the event's timezone so "monthly on the 15th" stays on the 15th
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: timeZoneIdentifier) ?? .current
        
        // Determine the DateComponents to add per iteration
        let components: DateComponents
        switch rule.frequency {
        case .daily:
            components = DateComponents(day: rule.interval)
        case .weekly:
            components = DateComponents(day: rule.interval * 7)
        case .monthly:
            components = DateComponents(month: rule.interval)
        case .yearly:
            components = DateComponents(year: rule.interval)
        case .none:
            return []
        }
        
        // COUNT in iCal includes the parent event itself, so children = count - 1
        let maxChildren = rule.count.map { $0 - 1 }
        let untilDate = rule.until
        
        var occurrences: [OccurrenceDate] = []
        var current = utcStart
        var generated = 0
        
        while true {
            guard let next = cal.date(byAdding: components, to: current) else { break }
            
            // Check termination conditions
            if next > horizon { break }
            if let until = untilDate, next > until { break }
            if let max = maxChildren, generated >= max { break }
            
            occurrences.append(OccurrenceDate(
                utcStart: next,
                utcEnd: next.addingTimeInterval(duration)
            ))
            
            current = next
            generated += 1
        }
        
        return occurrences
    }
}

// MARK: - EventBatchHandler (off main thread)

/// Handles batch import/export parsing and serialization off the main actor.
/// All methods are nonisolated and async — they do no SwiftData work directly.
final class EventBatchHandler: Sendable {
    
    // MARK: - Transfer Types
    
    /// Lightweight Sendable snapshot of a MetricEvent for crossing isolation boundaries
    struct EventSnapshot: Sendable {
        let id: String
        let title: String
        let notes: String
        let location: String
        let startYears: Int
        let startSeconds: Int
        let endYears: Int
        let endSeconds: Int
        let utcStart: Date
        let utcEnd: Date
        let timeZoneIdentifier: String
        let isAllDay: Bool
        let status: String
        let sequence: Int
        let recurrenceRule: String
        let recurringParentId: String
        let participantsJson: String
        let alarmsJson: String
        let calendarId: String
        let externalId: String
        let extendedProperties: String
        
        init(from event: MetricEvent) {
            self.id = event.id
            self.title = event.title
            self.notes = event.notes
            self.location = event.location
            self.startYears = event.startYears
            self.startSeconds = event.startSeconds
            self.endYears = event.endYears
            self.endSeconds = event.endSeconds
            self.utcStart = event.utcStart
            self.utcEnd = event.utcEnd
            self.timeZoneIdentifier = event.timeZoneIdentifier
            self.isAllDay = event.isAllDay
            self.status = event.status
            self.sequence = event.sequence
            self.recurrenceRule = event.recurrenceRule
            self.recurringParentId = event.recurringParentId
            self.participantsJson = event.participantsJson
            self.alarmsJson = event.alarmsJson
            self.calendarId = event.calendarId
            self.externalId = event.externalId
            self.extendedProperties = event.extendedProperties
        }
    }
    
    /// Parsed event data ready to be inserted into SwiftData on the main actor
    struct ParsedEvent: Sendable {
        let id: String
        let title: String
        let notes: String
        let location: String
        let startYears: Int
        let startSeconds: Int
        let endYears: Int
        let endSeconds: Int
        let utcStart: Date
        let utcEnd: Date
        let timeZoneIdentifier: String
        let isAllDay: Bool
        let status: String
        let sequence: Int
        let recurrenceRule: String
        let participantsJson: String
        let alarmsJson: String
        let calendarId: String
        let externalId: String
        let extendedProperties: String
    }
    
    enum BatchError: Error {
        case invalidFormat
        case missingRequiredField(String)
        case dateParsingFailed(String)
    }
    
    // MARK: - iCalendar Import
    
    /// Parse an iCalendar (.ics) string into ParsedEvent values.
    /// Supports VEVENT components with SUMMARY, DTSTART, DTEND, DESCRIPTION,
    /// LOCATION, STATUS, RRULE, SEQUENCE, and VALARM sub-components.
    static func parseICalendar(_ icalData: String) async throws -> [ParsedEvent] {
        // Unfold RFC 5545 continuation lines (CRLF + whitespace)
        let unfolded = icalData
            .replacingOccurrences(of: "\r\n ", with: "")
            .replacingOccurrences(of: "\r\n\t", with: "")
        
        let lines = unfolded.components(separatedBy: .newlines)
        var events: [ParsedEvent] = []
        var inEvent = false
        var inAlarm = false
        var props: [String: String] = [:]
        var alarmProps: [[String: String]] = []
        var currentAlarm: [String: String] = [:]
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            
            if trimmed == "BEGIN:VEVENT" {
                inEvent = true
                props = [:]
                alarmProps = []
                continue
            }
            if trimmed == "END:VEVENT" {
                if let parsed = try? buildParsedEvent(from: props, alarms: alarmProps) {
                    events.append(parsed)
                }
                inEvent = false
                continue
            }
            if trimmed == "BEGIN:VALARM" {
                inAlarm = true
                currentAlarm = [:]
                continue
            }
            if trimmed == "END:VALARM" {
                inAlarm = false
                alarmProps.append(currentAlarm)
                continue
            }
            
            guard inEvent else { continue }
            
            // Parse "KEY;params:VALUE" or "KEY:VALUE"
            if let colonRange = trimmed.range(of: ":", options: .literal) {
                let keyPart = String(trimmed[trimmed.startIndex..<colonRange.lowerBound])
                let value = String(trimmed[colonRange.upperBound...])
                // Strip parameters from key (e.g. DTSTART;TZID=America/New_York)
                let key = keyPart.components(separatedBy: ";").first ?? keyPart
                
                if inAlarm {
                    currentAlarm[key] = value
                } else {
                    props[key] = value
                    // Preserve full key with params for timezone extraction
                    if key == "DTSTART" || key == "DTEND" {
                        props[keyPart] = value
                        props["\(key)_FULL"] = keyPart
                    }
                }
            }
        }
        
        return events
    }
    
    /// Build a ParsedEvent from iCal property key-value pairs
    private static func buildParsedEvent(from props: [String: String], alarms: [[String: String]]) throws -> ParsedEvent {
        guard let summary = props["SUMMARY"], !summary.isEmpty else {
            throw BatchError.missingRequiredField("SUMMARY")
        }
        
        // Parse dates
        let tzId = extractTimezone(from: props["DTSTART_FULL"]) ?? TimeZone.current.identifier
        
        guard let dtstart = props["DTSTART"],
              let startDate = parseICalDate(dtstart) else {
            throw BatchError.missingRequiredField("DTSTART")
        }
        
        let isAllDay = dtstart.count == 8 // DATE only, no time component (e.g. 20260315)
        
        let endDate: Date
        if let dtend = props["DTEND"], let parsed = parseICalDate(dtend) {
            endDate = parsed
        } else if let duration = props["DURATION"] {
            endDate = startDate.addingTimeInterval(parseICalDuration(duration))
        } else {
            // Default: 1 metric second duration
            endDate = startDate.addingTimeInterval(0.864)
        }
        
        // Convert UTC dates to MetrixtTime
        let startMetrixt = UTCConverter.fromUTC(startDate, timeZoneIdentifier: tzId)
        let endMetrixt = UTCConverter.fromUTC(endDate, timeZoneIdentifier: tzId)
        
        // Parse alarms into EventAlarm JSON
        let parsedAlarms: [EventAlarm] = alarms.compactMap { alarmDict in
            guard let trigger = alarmDict["TRIGGER"] else { return nil }
            let offset = parseICalDuration(trigger)
            let action = alarmDict["ACTION"]?.lowercased() ?? "notification"
            let alarmType: EventAlarm.AlarmType
            switch action {
            case "email": alarmType = .email
            case "audio": alarmType = .sound
            default: alarmType = .notification
            }
            return EventAlarm(id: UUID().uuidString, offset: abs(offset), type: alarmType)
        }
        let alarmsJson = (try? JSONEncoder().encode(parsedAlarms)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        
        // Parse attendees if present
        let attendees = props.filter { $0.key.hasPrefix("ATTENDEE") }
        let participants: [EventParticipant] = attendees.map { (_, value) in
            let email = value.replacingOccurrences(of: "mailto:", with: "")
            return EventParticipant(
                id: UUID().uuidString,
                name: email.components(separatedBy: "@").first ?? email,
                email: email,
                role: .required,
                status: .needsAction
            )
        }
        let participantsJson = (try? JSONEncoder().encode(participants)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        
        let status = props["STATUS"] ?? "CONFIRMED"
        let sequence = Int(props["SEQUENCE"] ?? "0") ?? 0
        let rrule = props["RRULE"] ?? "NONE"
        let uid = props["UID"] ?? UUID().uuidString
        
        return ParsedEvent(
            id: UUID().uuidString,
            title: unescapeICalText(summary),
            notes: unescapeICalText(props["DESCRIPTION"] ?? ""),
            location: unescapeICalText(props["LOCATION"] ?? ""),
            startYears: startMetrixt.years,
            startSeconds: startMetrixt.seconds,
            endYears: endMetrixt.years,
            endSeconds: endMetrixt.seconds,
            utcStart: startDate,
            utcEnd: endDate,
            timeZoneIdentifier: tzId,
            isAllDay: isAllDay,
            status: status,
            sequence: sequence,
            recurrenceRule: rrule,
            participantsJson: participantsJson,
            alarmsJson: alarmsJson,
            calendarId: "IMPORTED",
            externalId: uid,
            extendedProperties: "{}"
        )
    }
    
    // MARK: - iCalendar Export
    
    /// Serialize event snapshots to a complete iCalendar (.ics) string
    static func serializeToICalendar(_ events: [EventSnapshot]) async -> String {
        var lines: [String] = []
        lines.append("BEGIN:VCALENDAR")
        lines.append("VERSION:2.0")
        lines.append("PRODID:-//Chronometrixt//MetricEvents//EN")
        lines.append("CALSCALE:GREGORIAN")
        lines.append("METHOD:PUBLISH")
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        
        for event in events {
            lines.append("BEGIN:VEVENT")
            lines.append("UID:\(event.id)")
            lines.append("DTSTAMP:\(isoFormatter.string(from: Date.now).replacingOccurrences(of: "-", with: "").replacingOccurrences(of: ":", with: ""))")
            
            if event.isAllDay {
                lines.append("DTSTART;VALUE=DATE:\(formatICalDateOnly(event.utcStart))")
                lines.append("DTEND;VALUE=DATE:\(formatICalDateOnly(event.utcEnd))")
            } else {
                lines.append("DTSTART:\(formatICalDateTime(event.utcStart))")
                lines.append("DTEND:\(formatICalDateTime(event.utcEnd))")
            }
            
            lines.append("SUMMARY:\(escapeICalText(event.title))")
            
            if !event.notes.isEmpty {
                lines.append("DESCRIPTION:\(escapeICalText(event.notes))")
            }
            if !event.location.isEmpty {
                lines.append("LOCATION:\(escapeICalText(event.location))")
            }
            
            lines.append("STATUS:\(event.status)")
            lines.append("SEQUENCE:\(event.sequence)")
            
            if event.recurrenceRule != "NONE" {
                lines.append("RRULE:\(event.recurrenceRule)")
            }
            
            // Serialize alarms
            if let data = event.alarmsJson.data(using: .utf8),
               let alarms = try? JSONDecoder().decode([EventAlarm].self, from: data) {
                for alarm in alarms {
                    lines.append("BEGIN:VALARM")
                    let action: String
                    switch alarm.type {
                    case .email: action = "EMAIL"
                    case .sound: action = "AUDIO"
                    case .notification: action = "DISPLAY"
                    }
                    lines.append("ACTION:\(action)")
                    lines.append("TRIGGER:\(formatICalDuration(-alarm.offset))")
                    lines.append("END:VALARM")
                }
            }
            
            // Include metric time as X-properties for lossless round-trip
            lines.append("X-METRIXT-START-YEARS:\(event.startYears)")
            lines.append("X-METRIXT-START-SECONDS:\(event.startSeconds)")
            lines.append("X-METRIXT-END-YEARS:\(event.endYears)")
            lines.append("X-METRIXT-END-SECONDS:\(event.endSeconds)")
            
            lines.append("END:VEVENT")
        }
        
        lines.append("END:VCALENDAR")
        return lines.joined(separator: "\r\n")
    }
    
    // MARK: - Google Calendar JSON Import
    
    /// Parse a Google Calendar JSON export into ParsedEvent values.
    /// Expects the format from Google Takeout or Calendar API (events list).
    static func parseGCalendarJSON(_ jsonString: String) async throws -> [ParsedEvent] {
        guard let data = jsonString.data(using: .utf8) else {
            throw BatchError.invalidFormat
        }
        
        let json: Any
        do {
            json = try JSONSerialization.jsonObject(with: data)
        } catch {
            throw BatchError.invalidFormat
        }
        
        // Support both { "items": [...] } wrapper and raw array
        let items: [[String: Any]]
        if let dict = json as? [String: Any], let arr = dict["items"] as? [[String: Any]] {
            items = arr
        } else if let arr = json as? [[String: Any]] {
            items = arr
        } else {
            throw BatchError.invalidFormat
        }
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let isoBasic = ISO8601DateFormatter()
        isoBasic.formatOptions = [.withInternetDateTime]
        
        var events: [ParsedEvent] = []
        
        for item in items {
            guard let summary = item["summary"] as? String, !summary.isEmpty else { continue }
            
            // Parse start
            guard let startDict = item["start"] as? [String: Any] else { continue }
            let startDate: Date
            let tzId: String
            var isAllDay = false
            
            if let dateStr = startDict["date"] as? String {
                // All-day event: "2026-03-15"
                isAllDay = true
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                df.timeZone = TimeZone(identifier: "UTC")
                guard let d = df.date(from: dateStr) else { continue }
                startDate = d
                tzId = (startDict["timeZone"] as? String) ?? TimeZone.current.identifier
            } else if let dateTimeStr = startDict["dateTime"] as? String {
                guard let d = isoFormatter.date(from: dateTimeStr) ?? isoBasic.date(from: dateTimeStr) else { continue }
                startDate = d
                tzId = (startDict["timeZone"] as? String) ?? TimeZone.current.identifier
            } else {
                continue
            }
            
            // Parse end
            let endDate: Date
            if let endDict = item["end"] as? [String: Any] {
                if let dateStr = endDict["date"] as? String {
                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd"
                    df.timeZone = TimeZone(identifier: "UTC")
                    endDate = df.date(from: dateStr) ?? startDate.addingTimeInterval(86400)
                } else if let dateTimeStr = endDict["dateTime"] as? String {
                    endDate = isoFormatter.date(from: dateTimeStr) ?? isoBasic.date(from: dateTimeStr) ?? startDate.addingTimeInterval(3600)
                } else {
                    endDate = startDate.addingTimeInterval(3600)
                }
            } else {
                endDate = startDate.addingTimeInterval(3600)
            }
            
            let startMetrixt = UTCConverter.fromUTC(startDate, timeZoneIdentifier: tzId)
            let endMetrixt = UTCConverter.fromUTC(endDate, timeZoneIdentifier: tzId)
            
            let status: String
            switch (item["status"] as? String)?.lowercased() {
            case "tentative": status = "TENTATIVE"
            case "cancelled": status = "CANCELLED"
            default: status = "CONFIRMED"
            }
            
            // Attendees
            let participants: [EventParticipant]
            if let attendees = item["attendees"] as? [[String: Any]] {
                participants = attendees.compactMap { att in
                    guard let email = att["email"] as? String else { return nil }
                    let name = (att["displayName"] as? String) ?? email.components(separatedBy: "@").first ?? email
                    let isOrganizer = (att["organizer"] as? Bool) ?? false
                    let role: EventParticipant.Role = isOrganizer ? .organizer : .required
                    let respStatus: EventParticipant.ParticipationStatus
                    switch att["responseStatus"] as? String {
                    case "accepted": respStatus = .accepted
                    case "declined": respStatus = .declined
                    case "tentative": respStatus = .tentative
                    default: respStatus = .needsAction
                    }
                    return EventParticipant(id: UUID().uuidString, name: name, email: email, role: role, status: respStatus)
                }
            } else {
                participants = []
            }
            let participantsJson = (try? JSONEncoder().encode(participants)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
            
            // Reminders -> alarms
            let alarms: [EventAlarm]
            if let reminders = item["reminders"] as? [String: Any],
               let overrides = reminders["overrides"] as? [[String: Any]] {
                alarms = overrides.compactMap { rem in
                    guard let minutes = rem["minutes"] as? Int else { return nil }
                    let method = rem["method"] as? String ?? "popup"
                    let alarmType: EventAlarm.AlarmType = method == "email" ? .email : .notification
                    return EventAlarm(id: UUID().uuidString, offset: TimeInterval(minutes * 60), type: alarmType)
                }
            } else {
                alarms = []
            }
            let alarmsJson = (try? JSONEncoder().encode(alarms)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
            
            // Recurrence
            let rrule: String
            if let recurrence = item["recurrence"] as? [String],
               let rruleLine = recurrence.first(where: { $0.hasPrefix("RRULE:") }) {
                rrule = String(rruleLine.dropFirst(6))
            } else {
                rrule = "NONE"
            }
            
            let gcalId = (item["id"] as? String) ?? UUID().uuidString
            
            events.append(ParsedEvent(
                id: UUID().uuidString,
                title: summary,
                notes: (item["description"] as? String) ?? "",
                location: (item["location"] as? String) ?? "",
                startYears: startMetrixt.years,
                startSeconds: startMetrixt.seconds,
                endYears: endMetrixt.years,
                endSeconds: endMetrixt.seconds,
                utcStart: startDate,
                utcEnd: endDate,
                timeZoneIdentifier: tzId,
                isAllDay: isAllDay,
                status: status,
                sequence: (item["sequence"] as? Int) ?? 0,
                recurrenceRule: rrule,
                participantsJson: participantsJson,
                alarmsJson: alarmsJson,
                calendarId: "GCAL",
                externalId: gcalId,
                extendedProperties: "{}"
            ))
        }
        
        return events
    }
    
    // MARK: - Google Calendar JSON Export
    
    /// Serialize event snapshots to Google Calendar-compatible JSON
    static func serializeToGCalendarJSON(_ events: [EventSnapshot]) async -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        
        var items: [[String: Any]] = []
        
        for event in events {
            var item: [String: Any] = [:]
            item["id"] = event.id
            item["summary"] = event.title
            item["status"] = event.status.lowercased()
            
            if !event.notes.isEmpty { item["description"] = event.notes }
            if !event.location.isEmpty { item["location"] = event.location }
            
            if event.isAllDay {
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                df.timeZone = TimeZone(identifier: "UTC")
                item["start"] = ["date": df.string(from: event.utcStart), "timeZone": event.timeZoneIdentifier]
                item["end"] = ["date": df.string(from: event.utcEnd), "timeZone": event.timeZoneIdentifier]
            } else {
                item["start"] = ["dateTime": isoFormatter.string(from: event.utcStart), "timeZone": event.timeZoneIdentifier]
                item["end"] = ["dateTime": isoFormatter.string(from: event.utcEnd), "timeZone": event.timeZoneIdentifier]
            }
            
            item["sequence"] = event.sequence
            
            if event.recurrenceRule != "NONE" {
                item["recurrence"] = ["RRULE:\(event.recurrenceRule)"]
            }
            
            // Participants
            if let data = event.participantsJson.data(using: .utf8),
               let participants = try? JSONDecoder().decode([EventParticipant].self, from: data),
               !participants.isEmpty {
                item["attendees"] = participants.map { p in
                    [
                        "email": p.email,
                        "displayName": p.name,
                        "organizer": p.role == .organizer,
                        "responseStatus": p.status.rawValue
                    ] as [String: Any]
                }
            }
            
            // Reminders
            if let data = event.alarmsJson.data(using: .utf8),
               let alarms = try? JSONDecoder().decode([EventAlarm].self, from: data),
               !alarms.isEmpty {
                let overrides = alarms.map { alarm in
                    [
                        "method": alarm.type == .email ? "email" : "popup",
                        "minutes": Int(alarm.offset / 60)
                    ] as [String: Any]
                }
                item["reminders"] = ["useDefault": false, "overrides": overrides] as [String: Any]
            }
            
            // Preserve metric time as extended properties
            item["extendedProperties"] = [
                "private": [
                    "metrixtStartYears": String(event.startYears),
                    "metrixtStartSeconds": String(event.startSeconds),
                    "metrixtEndYears": String(event.endYears),
                    "metrixtEndSeconds": String(event.endSeconds)
                ]
            ]
            
            items.append(item)
        }
        
        let wrapper: [String: Any] = ["items": items]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: wrapper, options: [.prettyPrinted, .sortedKeys]) else {
            return "{\"items\":[]}"
        }
        return String(data: jsonData, encoding: .utf8) ?? "{\"items\":[]}"
    }
    
    // MARK: - iCal Date Helpers
    
    /// Parse iCal date formats: "20260315T120000Z", "20260315T120000", "20260315"
    private static func parseICalDate(_ string: String) -> Date? {
        let clean = string.trimmingCharacters(in: .whitespaces)
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        
        if clean.hasSuffix("Z") {
            df.timeZone = TimeZone(identifier: "UTC")
            df.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
            return df.date(from: clean)
        } else if clean.contains("T") {
            df.timeZone = TimeZone.current
            df.dateFormat = "yyyyMMdd'T'HHmmss"
            return df.date(from: clean)
        } else if clean.count == 8 {
            df.timeZone = TimeZone(identifier: "UTC")
            df.dateFormat = "yyyyMMdd"
            return df.date(from: clean)
        }
        return nil
    }
    
    /// Parse iCal duration format: "-PT15M", "PT1H30M", "P1D"
    private static func parseICalDuration(_ string: String) -> TimeInterval {
        let clean = string.trimmingCharacters(in: .whitespaces)
        let isNegative = clean.hasPrefix("-")
        let stripped = clean.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "+", with: "")
        
        var total: TimeInterval = 0
        var current = ""
        var inTimePart = false
        
        for char in stripped {
            switch char {
            case "P": continue
            case "T": inTimePart = true
            case "W":
                total += (Double(current) ?? 0) * 604800
                current = ""
            case "D":
                total += (Double(current) ?? 0) * 86400
                current = ""
            case "H":
                total += (Double(current) ?? 0) * 3600
                current = ""
            case "M":
                if inTimePart {
                    total += (Double(current) ?? 0) * 60
                } else {
                    total += (Double(current) ?? 0) * 2592000 // ~30 days
                }
                current = ""
            case "S":
                total += Double(current) ?? 0
                current = ""
            default:
                current.append(char)
            }
        }
        
        return isNegative ? -total : total
    }
    
    /// Format a Date as iCal UTC datetime: "20260315T120000Z"
    private static func formatICalDateTime(_ date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(identifier: "UTC")
        df.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        return df.string(from: date)
    }
    
    /// Format a Date as iCal date-only: "20260315"
    private static func formatICalDateOnly(_ date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(identifier: "UTC")
        df.dateFormat = "yyyyMMdd"
        return df.string(from: date)
    }
    
    /// Format a TimeInterval as iCal duration: "-PT15M"
    private static func formatICalDuration(_ seconds: TimeInterval) -> String {
        let isNegative = seconds < 0
        let abs = abs(Int(seconds))
        let prefix = isNegative ? "-" : ""
        
        if abs >= 86400 && abs % 86400 == 0 {
            return "\(prefix)P\(abs / 86400)D"
        }
        
        let hours = abs / 3600
        let minutes = (abs % 3600) / 60
        let secs = abs % 60
        
        var result = "\(prefix)PT"
        if hours > 0 { result += "\(hours)H" }
        if minutes > 0 { result += "\(minutes)M" }
        if secs > 0 || (hours == 0 && minutes == 0) { result += "\(secs)S" }
        
        return result
    }
    
    /// Extract TZID parameter from a full iCal property key like "DTSTART;TZID=America/New_York"
    private static func extractTimezone(from fullKey: String?) -> String? {
        guard let key = fullKey else { return nil }
        let parts = key.components(separatedBy: ";")
        for part in parts {
            if part.hasPrefix("TZID=") {
                return String(part.dropFirst(5))
            }
        }
        return nil
    }
    
    /// Unescape iCal text: \\n -> newline, \\, -> comma, \\\\ -> backslash
    private static func unescapeICalText(_ text: String) -> String {
        text.replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\\,", with: ",")
            .replacingOccurrences(of: "\\;", with: ";")
            .replacingOccurrences(of: "\\\\", with: "\\")
    }
    
    /// Escape text for iCal output
    private static func escapeICalText(_ text: String) -> String {
        text.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: ",", with: "\\,")
            .replacingOccurrences(of: ";", with: "\\;")
    }
}

///ToDo:
///Recurrence rule implementation
///
