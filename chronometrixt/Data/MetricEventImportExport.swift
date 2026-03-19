//
//  MetricEventImportExport.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/19/26.
//

import Foundation

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
