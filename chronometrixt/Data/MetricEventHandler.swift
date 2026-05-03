//
//  MetricEventHandler.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/19/26.
//

import Foundation
import SwiftData

struct EventHandler {
    
    // MARK: - Build Event (pure data translation, no insertion)
    
    /// Build a MetricEvent from EventGovernor state. Does NOT insert into context.
    static func buildEvent(from eg: EventComptroller) throws -> MetricEvent {
        guard !eg.title.isEmpty else {
            throw EventError.invalidTitle
        }
        
        let utcStart = UTCConverter.toUTC(from: eg.metricStart)
        let utcEnd = UTCConverter.toUTC(from: eg.metricEnd)
        
        guard utcEnd > utcStart else {
            throw EventError.invalidTimeRange
        }
        
        let participantsJson = try encodeToJson(eg.participants)
        let alarmsJson = try encodeToJson(eg.alarms)
        let recurrenceString = eg.recurrence.frequency != .none ? eg.recurrence.toRRULE() : "NONE"
        
        return MetricEvent(
            id: UUID().uuidString,
            title: eg.title,
            notes: eg.notes,
            location: eg.location,
            startYears: eg.metricStart.years,
            startSeconds: eg.metricStart.seconds,
            endYears: eg.metricEnd.years,
            endSeconds: eg.metricEnd.seconds,
            utcStart: utcStart,
            utcEnd: utcEnd,
            timeZoneIdentifier: eg.metricStart.creationTimeZone.identifier,
            isAllDay: eg.isAllDay,
            status: eg.status.rawValue,
            sequence: 0,
            recurrenceRule: recurrenceString,
            recurringParentId: "NONE",
            participantsJson: participantsJson,
            alarmsJson: alarmsJson,
            calendarId: eg.calendar,
            calendarColor: eg.calendarColor,
            externalId: "NONE"
        )
    }
    
    // MARK: - Apply Updates
    
    /// Write all EventGovernor fields onto an existing MetricEvent.
    static func applyUpdates(to event: MetricEvent, from eg: EventComptroller) throws {
        guard !eg.title.isEmpty else { throw EventError.invalidTitle }
        
        let utcStart = UTCConverter.toUTC(from: eg.metricStart)
        let utcEnd = UTCConverter.toUTC(from: eg.metricEnd)
        guard utcEnd > utcStart else { throw EventError.invalidTimeRange }
        
        event.title = eg.title
        event.notes = eg.notes
        event.location = eg.location
        event.startYears = eg.metricStart.years
        event.startSeconds = eg.metricStart.seconds
        event.endYears = eg.metricEnd.years
        event.endSeconds = eg.metricEnd.seconds
        event.utcStart = utcStart
        event.utcEnd = utcEnd
        event.isAllDay = eg.isAllDay
        event.status = eg.status.rawValue
        event.participantsJson = try encodeToJson(eg.participants)
        event.alarmsJson = try encodeToJson(eg.alarms)
        event.recurrenceRule = eg.recurrence.frequency != .none ? eg.recurrence.toRRULE() : "NONE"
        event.calendarId = eg.calendar
        event.calendarColor = eg.calendarColor
        event.sequence += 1
    }
    
    // MARK: - Encoding/Decoding Helpers
    
    static func encodeToJson<T: Encodable>(_ value: T) throws -> String {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        return String(data: data, encoding: .utf8) ?? "[]"
    }
    
    static func decodeFromJson<T: Decodable>(_ json: String, as type: T.Type) throws -> T {
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
    
    static func fetchEvents(forYear year: Int, inRange secondsRange: Range<Int>, context: ModelContext) -> [MetricEvent] {
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
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching events: \(error)")
            return []
        }
    }
    
    static func fetchRecentEvents(around time: MetrixtTime, rangeDays: Int = 1, context: ModelContext) -> [MetricEvent] {
        let secondsPerDay = 100_000
        let rangeSeconds = secondsPerDay * rangeDays
        
        let lowerBound = max(0, time.seconds - rangeSeconds)
        let upperBound = time.seconds + rangeSeconds
        
        return fetchEvents(forYear: time.years, inRange: lowerBound..<upperBound, context: context)
    }
    
    static func fetchAllEvents(context: ModelContext) -> [MetricEvent] {
        let descriptor = FetchDescriptor<MetricEvent>(
            sortBy: [SortDescriptor(\.startYears), SortDescriptor(\.startSeconds)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching all events: \(error)")
            return []
        }
    }
    
    // MARK: - Decode Complex Properties
    
    static func participants(for event: MetricEvent) -> [EventParticipant] {
        guard let decoded = try? decodeFromJson(event.participantsJson, as: [EventParticipant].self) else {
            return []
        }
        return decoded
    }
    
    static func alarms(for event: MetricEvent) -> [EventAlarm] {
        guard let decoded = try? decodeFromJson(event.alarmsJson, as: [EventAlarm].self) else {
            return []
        }
        return decoded
    }
    
    static func recurrenceRule(for event: MetricEvent) -> RecurrenceRule {
        if event.recurrenceRule == "NONE" {
            return .none
        }
        return RecurrenceRule.fromRRULE(event.recurrenceRule)
    }
    
    // MARK: - Destroy Events
    
    /// Delete a single event instance (a child, or a standalone non-recurring event).
    static func destroySingleEvent(_ event: MetricEvent, context: ModelContext) {
        if event.recurringParentId != "NONE" || !hasRecurringChildren(event, context: context) {
            context.delete(event)
        }
    }
    
    /// Delete an entire recurring series: parent + all children.
    static func destroyEventSeries(_ event: MetricEvent, context: ModelContext) {
        let parentId = event.recurringParentId != "NONE" ? event.recurringParentId : event.id
        
        let childPredicate = #Predicate<MetricEvent> { e in
            e.recurringParentId == parentId
        }
        if let children = try? context.fetch(FetchDescriptor<MetricEvent>(predicate: childPredicate)) {
            for child in children {
                context.delete(child)
            }
        }
        
        let parentPredicate = #Predicate<MetricEvent> { e in
            e.id == parentId
        }
        if let parents = try? context.fetch(FetchDescriptor<MetricEvent>(predicate: parentPredicate)),
           let parent = parents.first {
            context.delete(parent)
        }
    }
    
    /// Delete this event and all future siblings in the series.
    static func destroyThisAndFuture(_ event: MetricEvent, context: ModelContext) {
        guard event.recurringParentId != "NONE" else {
            destroyEventSeries(event, context: context)
            return
        }
        
        let parentId = event.recurringParentId
        let cutoffStart = event.utcStart
        
        let futurePredicate = #Predicate<MetricEvent> { e in
            e.recurringParentId == parentId && e.utcStart >= cutoffStart
        }
        if let futureChildren = try? context.fetch(FetchDescriptor<MetricEvent>(predicate: futurePredicate)) {
            for child in futureChildren {
                context.delete(child)
            }
        }
        
        let parentPredicate = #Predicate<MetricEvent> { e in
            e.id == parentId
        }
        if let parents = try? context.fetch(FetchDescriptor<MetricEvent>(predicate: parentPredicate)),
           let parent = parents.first {
            var rule = RecurrenceRule.fromRRULE(parent.recurrenceRule)
            rule.until = cutoffStart.addingTimeInterval(-1)
            rule.count = nil
            parent.recurrenceRule = rule.toRRULE()
            parent.sequence += 1
        }
    }
    
    /// Check if an event has recurring children
    private static func hasRecurringChildren(_ event: MetricEvent, context: ModelContext) -> Bool {
        let eventId = event.id
        let predicate = #Predicate<MetricEvent> { e in
            e.recurringParentId == eventId
        }
        let descriptor = FetchDescriptor<MetricEvent>(predicate: predicate)
        do {
            let children = try context.fetch(descriptor)
            return !children.isEmpty
        } catch {
            return false
        }
    }
    
    /// Get all alarm IDs from an event and all its recurring instances
    static func allAlarmIds(for event: MetricEvent, context: ModelContext) -> [String] {
        var alarmIds: [String] = []
        
        // Get the parent ID (either this event or its parent)
        let parentId = event.recurringParentId != "NONE" ? event.recurringParentId : event.id
        
        // Fetch all events in the series (parent + children)
        let seriesPredicate = #Predicate<MetricEvent> { e in
            e.id == parentId || e.recurringParentId == parentId
        }
        
        guard let seriesEvents = try? context.fetch(FetchDescriptor<MetricEvent>(predicate: seriesPredicate)) else {
            return []
        }
        
        // Extract alarm IDs from each event
        for event in seriesEvents {
            let eventAlarms = alarms(for: event)
            alarmIds.append(contentsOf: eventAlarms.map { $0.id })
        }
        
        return alarmIds
    }

    /// Get alarm IDs from this event and all future instances
    static func futureAlarmIds(for event: MetricEvent, context: ModelContext) -> [String] {
        var alarmIds: [String] = []
        
        guard event.recurringParentId != "NONE" else {
            // Not a recurring instance, treat as full series
            return allAlarmIds(for: event, context: context)
        }
        
        let parentId = event.recurringParentId
        let cutoffStart = event.utcStart
        
        // Fetch future events in the series
        let futurePredicate = #Predicate<MetricEvent> { e in
            e.recurringParentId == parentId && e.utcStart >= cutoffStart
        }
        
        guard let futureEvents = try? context.fetch(FetchDescriptor<MetricEvent>(predicate: futurePredicate)) else {
            return []
        }
        
        // Extract alarm IDs from future events
        for event in futureEvents {
            let eventAlarms = alarms(for: event)
            alarmIds.append(contentsOf: eventAlarms.map { $0.id })
        }
        
        return alarmIds
    }
    
    // MARK: - Edit Propagation
    
    /// Update all events in a series from EventGovernor data.
    static func updateEventSeries(_ event: MetricEvent, from eg: EventComptroller, context: ModelContext) throws {
        let parentId = event.recurringParentId != "NONE" ? event.recurringParentId : event.id
        let parentPredicate = #Predicate<MetricEvent> { e in e.id == parentId }
        guard let parents = try? context.fetch(FetchDescriptor<MetricEvent>(predicate: parentPredicate)),
              let parent = parents.first else { return }
        
        try applyUpdates(to: parent, from: eg)
        
        let childPredicate = #Predicate<MetricEvent> { e in e.recurringParentId == parentId }
        if let children = try? context.fetch(FetchDescriptor<MetricEvent>(predicate: childPredicate)) {
            for child in children { context.delete(child) }
        }
        
        try materializeRecurrences(for: parent, context: context)
    }
    
    /// Update this event and all future siblings: splits the series.
    static func updateThisAndFuture(_ event: MetricEvent, from eg: EventComptroller, context: ModelContext) throws {
        guard event.recurringParentId != "NONE" else {
            try updateEventSeries(event, from: eg, context: context)
            return
        }
        
        let oldParentId = event.recurringParentId
        let cutoffStart = event.utcStart
        
        let parentPredicate = #Predicate<MetricEvent> { e in e.id == oldParentId }
        guard let parents = try? context.fetch(FetchDescriptor<MetricEvent>(predicate: parentPredicate)),
              let oldParent = parents.first else { return }
        let originalRrule = oldParent.recurrenceRule
        
        let futurePredicate = #Predicate<MetricEvent> { e in
            e.recurringParentId == oldParentId && e.utcStart >= cutoffStart
        }
        if let futureChildren = try? context.fetch(FetchDescriptor<MetricEvent>(predicate: futurePredicate)) {
            for child in futureChildren { context.delete(child) }
        }
        
        var truncatedRule = RecurrenceRule.fromRRULE(originalRrule)
        truncatedRule.until = cutoffStart.addingTimeInterval(-1)
        truncatedRule.count = nil
        oldParent.recurrenceRule = truncatedRule.toRRULE()
        oldParent.sequence += 1
        
        let newStartTime = eg.metricStart
//        let duration = oldParent.utcEnd.timeIntervalSince(oldParent.utcStart)
        let newUtcStart = UTCConverter.toUTC(from: newStartTime)
        let newEndTime = eg.metricEnd
        let newUtcEnd = UTCConverter.toUTC(from: newEndTime)
        
        let participantsJson = try encodeToJson(eg.participants)
        let alarmsJson = try encodeToJson(eg.alarms)
        
        let newParent = MetricEvent(
            id: UUID().uuidString,
            title: eg.title,
            notes: eg.notes,
            location: eg.location,
            startYears: newStartTime.years,
            startSeconds: newStartTime.seconds,
            endYears: newEndTime.years,
            endSeconds: newEndTime.seconds,
            utcStart: newUtcStart,
            utcEnd: newUtcEnd,
            timeZoneIdentifier: oldParent.timeZoneIdentifier,
            isAllDay: eg.isAllDay,
            status: eg.status.rawValue,
            sequence: 0,
            recurrenceRule: originalRrule,
            recurringParentId: "NONE",
            participantsJson: participantsJson,
            alarmsJson: alarmsJson,
            calendarId: eg.calendar,
            calendarColor: eg.calendarColor,
            externalId: "NONE",
            extendedProperties: oldParent.extendedProperties
        )
        
        context.insert(newParent)
        try materializeRecurrences(for: newParent, context: context)
    }
    
    // MARK: - Import/Export
    
    static func importFromICalendar(_ icalData: String, context: ModelContext) async throws -> [MetricEvent] {
        let parsed = try await EventBatchHandler.parseICalendar(icalData)
        return try insertParsedEvents(parsed, context: context)
    }
    
    static func importFromGCalendar(_ gcalData: String, context: ModelContext) async throws -> [MetricEvent] {
        let parsed = try await EventBatchHandler.parseGCalendarJSON(gcalData)
        return try insertParsedEvents(parsed, context: context)
    }
    
    static func exportToICalendar(context: ModelContext) async -> String {
        let events = fetchParentEvents(context: context)
        let snapshots = events.map { EventBatchHandler.EventSnapshot(from: $0) }
        return await EventBatchHandler.serializeToICalendar(snapshots)
    }
    
    static func exportToGCalendarJSON(context: ModelContext) async -> String {
        let events = fetchParentEvents(context: context)
        let snapshots = events.map { EventBatchHandler.EventSnapshot(from: $0) }
        return await EventBatchHandler.serializeToGCalendarJSON(snapshots)
    }
    
    /// Insert parsed event data into the model context
    private static func insertParsedEvents(_ parsed: [EventBatchHandler.ParsedEvent], context: ModelContext) throws -> [MetricEvent] {
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
                calendarColor: p.calendarColor,
                externalId: p.externalId,
                extendedProperties: p.extendedProperties
            )
            context.insert(event)
            created.append(event)
        }
        
        for event in created where event.recurrenceRule != "NONE" {
            try materializeRecurrences(for: event, context: context)
        }
        
        return created
    }
    
    // MARK: - Recurrence Materialization
    
    @discardableResult
    static func materializeRecurrences(
        for parent: MetricEvent,
        horizon: Date? = nil,
        context: ModelContext
    ) throws -> [MetricEvent] {
        guard parent.recurrenceRule != "NONE" else { return [] }
        
        let effectiveHorizon = horizon ?? Calendar.current.date(byAdding: .year, value: 2, to: parent.utcStart)!
        
        let parentId = parent.id
        let childPredicate = #Predicate<MetricEvent> { e in
            e.recurringParentId == parentId
        }
        let existingChildren = (try? context.fetch(FetchDescriptor<MetricEvent>(predicate: childPredicate))) ?? []
        let existingStarts = Set(existingChildren.map { Int($0.utcStart.timeIntervalSince1970) })
        
        let occurrences = RecurrenceExpander.expand(
            rruleString: parent.recurrenceRule,
            utcStart: parent.utcStart,
            utcEnd: parent.utcEnd,
            timeZoneIdentifier: parent.timeZoneIdentifier,
            horizon: effectiveHorizon
        )
        
        var created: [MetricEvent] = []
        
        for occ in occurrences {
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
                calendarColor: parent.calendarColor,
                externalId: "NONE",
                extendedProperties: parent.extendedProperties
            )
            
            context.insert(child)
            created.append(child)
        }
        
        return created
    }
    
    /// Fetch only parent events (not recurring children). Used for export.
    static func fetchParentEvents(context: ModelContext) -> [MetricEvent] {
        let predicate = #Predicate<MetricEvent> { event in
            event.recurringParentId == "NONE"
        }
        let descriptor = FetchDescriptor<MetricEvent>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.startYears), SortDescriptor(\.startSeconds)]
        )
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching parent events: \(error)")
            return []
        }
    }
    
    // MARK: - Horizon Refresh
    
    static func refreshMaterializationHorizons(context: ModelContext) throws {
        let now = Date.now
        let threeMonthsFromNow = Calendar.current.date(byAdding: .month, value: 3, to: now)!
        let newHorizon = Calendar.current.date(byAdding: .year, value: 2, to: now)!
        
        let noneString = "NONE"
        let predicate = #Predicate<MetricEvent> { e in
            e.recurrenceRule != noneString && e.recurringParentId == noneString
        }
        let parents = (try? context.fetch(FetchDescriptor<MetricEvent>(predicate: predicate))) ?? []
        
        for parent in parents {
            let parentId = parent.id
            let childPredicate = #Predicate<MetricEvent> { e in
                e.recurringParentId == parentId
            }
            var descriptor = FetchDescriptor<MetricEvent>(predicate: childPredicate)
            descriptor.sortBy = [SortDescriptor(\.utcStart, order: .reverse)]
            descriptor.fetchLimit = 1
            
            if let lastChild = (try? context.fetch(descriptor))?.first {
                if lastChild.utcStart < threeMonthsFromNow {
                    try materializeRecurrences(for: parent, horizon: newHorizon, context: context)
                }
            }
        }
    }
    
    // MARK: - Extend Recurrences

    /// Extend materialized recurrences to maintain lookAheadYears into the future
    static func extendRecurrences(
        for parent: MetricEvent,
        context: ModelContext,
        lookAheadYears: Int = 2
    ) throws {
        // Find the latest materialized child
        let parentId = parent.id
        let childPredicate = #Predicate<MetricEvent> { event in
            event.recurringParentId == parentId
        }
        
        let sortDescriptor = SortDescriptor(\MetricEvent.utcStart, order: .reverse)
        let descriptor = FetchDescriptor<MetricEvent>(
            predicate: childPredicate,
            sortBy: [sortDescriptor]
        )
        
        let children = try context.fetch(descriptor)
        
        // Determine the cutoff date (lookAheadYears from now)
        let cutoffDate = Calendar.current.date(
            byAdding: .year,
            value: lookAheadYears,
            to: Date.now
        ) ?? Date.now.addingTimeInterval(TimeInterval(lookAheadYears * 365 * 86400))
        
        // If latest child is already beyond cutoff, we're good
        if let latestChild = children.first, latestChild.utcStart >= cutoffDate {
            return
        }
        
        // Otherwise, materialize more instances
        let rule = RecurrenceRule.fromRRULE(parent.recurrenceRule).toRRULE()
        
        // Start from the latest child or from parent
        let startDate = children.first?.utcStart ?? parent.utcStart
        
        // Expand from startDate to cutoffDate
        let newOccurrences = RecurrenceExpander.expand(
            rruleString: rule,
            utcStart: startDate.addingTimeInterval(1), // Start after last instance
            utcEnd: cutoffDate,
            timeZoneIdentifier: parent.timeZoneIdentifier,
            horizon: parent.utcEnd
        )
        
        // Materialize each occurrence
        for occurrence in newOccurrences {
            let metricStart = MetrixtTime(date: occurrence.utcStart)
            let metricEnd = MetrixtTime(date: occurrence.utcEnd)
            
            let child = MetricEvent(
                id: UUID().uuidString,
                title: parent.title,
                notes: parent.notes,
                location: parent.location,
                startYears: metricStart.years,
                startSeconds: metricStart.seconds,
                endYears: metricEnd.years,
                endSeconds: metricEnd.seconds,
                utcStart: occurrence.utcStart,
                utcEnd: occurrence.utcEnd,
                timeZoneIdentifier: parent.timeZoneIdentifier,
                isAllDay: parent.isAllDay,
                status: parent.status,
                sequence: parent.sequence,
                recurrenceRule: "NONE",
                recurringParentId: parent.id,
                participantsJson: parent.participantsJson,
                alarmsJson: parent.alarmsJson,
                calendarId: parent.calendarId,
                calendarColor: parent.calendarColor,
                externalId: ""
            )
            
            context.insert(child)
        }
        
        print("✅ Extended recurrences for \(parent.title): added \(newOccurrences.count) instances")
    }
}

// MARK: - UTC Converter

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

// MARK: - Event Status

enum EventStatus: String, Codable, Sendable {
    case confirmed = "CONFIRMED"
    case tentative = "TENTATIVE"
    case cancelled = "CANCELLED"
}

// MARK: - Recurrence Rule

///ADDED METRIC TO THIS - DEAL WITH ITERATION AND EXPORT IMPLICATIONS!!!
///
///  |
///  V
struct RecurrenceRule: Codable, Sendable, Hashable {
    enum Frequency: String, Codable, Sendable {
        case daily, weekly, metricWeekly, monthly, metricMonthly, yearly, none
    }
    
    var frequency: Frequency
    var interval: Int // every X days/weeks/months
    var count: Int? // end after X occurrences
    var until: Date? // or end on specific date
    
    static let none = RecurrenceRule(frequency: .none, interval: 1, count: nil, until: nil)
    
    // MARK: - Count ↔ Until Synchronization
    
    /// Compute how many occurrences fit between `startDate` and `untilDate`
    /// for the current frequency/interval. Returns total count including the first occurrence.
    static func countFromUntil(startDate: Date, untilDate: Date, frequency: Frequency, interval: Int = 1) -> Int {
        guard frequency != .none, untilDate > startDate else { return 1 }
        
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        
        let step = stepComponents(for: frequency, interval: interval)
        
        var count = 1 // the first occurrence (the parent)
        var current = startDate
        
        while let next = cal.date(byAdding: step, to: current), next <= untilDate {
            count += 1
            current = next
        }
        
        return count
    }
    
    /// Compute the end date for a given count of occurrences from `startDate`
    /// for the current frequency/interval. Returns the date of the last occurrence.
    static func untilFromCount(startDate: Date, count: Int, frequency: Frequency, interval: Int = 1) -> Date {
        guard frequency != .none, count > 1 else { return startDate }
        
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        
        let step = stepComponents(for: frequency, interval: interval)
        
        var current = startDate
        // count includes the first occurrence, so step (count - 1) times
        for _ in 1..<count {
            guard let next = cal.date(byAdding: step, to: current) else { break }
            current = next
        }
        
        return current
    }
    
    /// DateComponents for one step of a given frequency
    private static func stepComponents(for frequency: Frequency, interval: Int) -> DateComponents {
        switch frequency {
        case .daily:         return DateComponents(day: interval)
        case .weekly:        return DateComponents(day: interval * 7)
        case .metricWeekly:  return DateComponents(day: interval * 10)
        case .monthly:       return DateComponents(month: interval)
        case .metricMonthly: return DateComponents(day: interval * 100)
        case .yearly:        return DateComponents(year: interval)
        case .none:          return DateComponents()
        }
    }
    
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

// MARK: - Event Participant

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

// MARK: - Event Alarm

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
        case .metricWeekly:
            components = DateComponents(day: rule.interval * 10)
        case .monthly:
            components = DateComponents(month: rule.interval)
        case .metricMonthly:
            components = DateComponents(day: rule.interval * 100)
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
