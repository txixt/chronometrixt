//
//  MetricEventHandler.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/19/26.
//

import Foundation
import SwiftData

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

// MARK: - Event Supporting Types

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

struct EventAlarm: Codable, Identifiable, Sendable, Hashable {
    var id: String
    var offset: TimeInterval // seconds before event
    var type: AlarmType
    
    enum AlarmType: String, Codable, Sendable {
        case notification, email, sound
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
