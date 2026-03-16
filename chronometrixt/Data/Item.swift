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
         externalId: String
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
    }
}

final class UTCConverter {
    
    /// Convert MetrixtTime to UTC Date (no local timezone adjustments)
    /// Unlike toGreg(), this returns a pure UTC timestamp
    static func toUTC(from metrixtTime: MetrixtTime) -> Date {
        // Get the base Gregorian year (subtract the 3030 offset)
        let gregYear = metrixtTime.years - 3030
        
        // Create Jan 1 of that year at midnight UTC
        guard let yearStart = Calendar.current.date(from: DateComponents(
            calendar: Calendar.current,
            timeZone: TimeZone(identifier: "UTC"),
            year: gregYear,
            month: 1,
            day: 1
        )) else {
            return Date(timeIntervalSince1970: 0)
        }
        
        // Add the seconds (converted from metric seconds to gregorian seconds)
        // Each metric second = 0.864 gregorian seconds
        let gregorianSeconds = Double(metrixtTime.seconds) * 0.864
        return yearStart.addingTimeInterval(gregorianSeconds)
    }
    
    /// Convert UTC Date to MetrixtTime (preserving the source timezone identifier)
    /// This creates a MetrixtTime that when converted back will match the UTC moment
    static func fromUTC(_ utcDate: Date, timeZoneIdentifier: String) -> MetrixtTime {
        // Work in the specified timezone
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: timeZoneIdentifier) ?? .current
        
        // Extract the year and create year start in that timezone
        let gregYear = calendar.component(.year, from: utcDate)
        let metrixtYear = gregYear + 3030
        
        guard let yearStart = calendar.date(from: DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: gregYear,
            month: 1,
            day: 1
        )) else {
            return MetrixtTime(years: metrixtYear, seconds: 0)
        }
        
        // Calculate seconds elapsed since year start in gregorian
        let gregorianSecondsIntoYear = utcDate.timeIntervalSince(yearStart)
        
        // Convert to metric seconds (each gregorian second = 1.1574... metric seconds)
        let metrixtSeconds = Int(gregorianSecondsIntoYear / 0.864)
        
        return MetrixtTime(years: metrixtYear, seconds: metrixtSeconds)
    }
    
    /// Get the current time zone offset from UTC in seconds
    /// Useful for debugging or displaying timezone info
    static func currentOffsetFromUTC() -> Int {
        return TimeZone.current.secondsFromGMT()
    }
    
    /// Convert a MetrixtTime to a local Date in a specific timezone
    /// This is a convenience wrapper that combines toUTC with timezone adjustment
    static func toLocal(from metrixtTime: MetrixtTime, timeZoneIdentifier: String) -> Date {
        let utcDate = toUTC(from: metrixtTime)
        
        guard let targetTimeZone = TimeZone(identifier: timeZoneIdentifier) else {
            return utcDate
        }
        
        // The UTC date is the absolute moment in time
        // When displayed in the local timezone, it will show correctly
        return utcDate
    }
}

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
    func destroyEvent(_ event: MetricEvent) -> Bool {
        guard !hasRecurringChildren(event) else { return false }
        modelContext.delete(event)
        return true
    }
    
    func destroyRelatedEvents(_ event: MetricEvent) {
        let predicate = #Predicate<MetricEvent> { e in
            e.recurringParentId == event.id
        }
        let descriptor = FetchDescriptor<MetricEvent>(predicate: predicate)
        let progeny = try! modelContext.fetch(descriptor)
        
        for kiddo in progeny {
            modelContext.delete(kiddo)
        }
    }
    
    /// Check if an event has recurring children
    private func hasRecurringChildren(_ event: MetricEvent) -> Bool {
        let predicate = #Predicate<MetricEvent> { e in
            e.recurringParentId == event.id
        }
        
        let descriptor = FetchDescriptor<MetricEvent>(predicate: predicate)
        
        do {
            let children = try modelContext.fetch(descriptor)
            return !children.isEmpty
        } catch {
            return false
        }
    }
    
    // MARK: - Import/Export
    func importFromICalendar(_ icalData: String) throws -> [MetricEvent] {
        // Parse iCal format and create events
        return []
    }
    
    func exportToiCal() -> [String] {
        //.ics format?
        return []
    }
    
    func exportTogCal() -> [String] {
        //json?
        return []
    }
    
    
    enum EventStatus: String, Codable {
        case confirmed = "CONFIRMED"
        case tentative = "TENTATIVE"
        case cancelled = "CANCELLED"
    }
    struct RecurrenceRule: Codable {
        enum Frequency: String, Codable {
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
    struct EventParticipant: Codable, Identifiable {
        var id: String
        var name: String
        var email: String
        var role: Role
        var status: ParticipationStatus
        
        enum Role: String, Codable {
            case organizer, required, optional
        }
        
        enum ParticipationStatus: String, Codable {
            case accepted, declined, tentative, needsAction
        }
    }
    struct EventAlarm: Codable, Identifiable {
        var id: String
        var offset: TimeInterval // seconds before event
        var type: AlarmType
        
        enum AlarmType: String, Codable {
            case notification, email, sound
        }
    }

}

