//
//  MetrixtCalendar.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/22/26.
//

import Foundation
import SwiftUI
import SwiftData

@Model final class MetricCalendar {
    var id: String
    var name: String
    var colorHex: String        // e.g. "#FF6B35"
    var isVisible: Bool         // toggle calendar visibility
    var source: String          // "local", "ical", "gcal"
    var externalId: String      // for sync — maps to EKCalendar identifier, etc.
    var isReadOnly: Bool        // imported calendars might be read-only
    
    init(id: String, name: String, colorHex: String, isVisible: Bool, source: String, externalId: String, isReadOnly: Bool) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.isVisible = isVisible
        self.source = source
        self.externalId = externalId
        self.isReadOnly = isReadOnly
    }
}

extension Color {
    /// Create a Color from a hex string. Accepts "FF6B35", "#FF6B35", or "0xFF6B35".
    init(hex: String) {
        let cleaned = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "0x", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        
        self.init(red: r, green: g, blue: b)
    }
}

struct CalInitializer {
    static func first () -> MetricCalendar {
        return MetricCalendar(id: UUID().uuidString,
                              name: "metrixt",
                              colorHex: "#015659",
                              isVisible: true,
                              source: "user",
                              externalId: "metrixt1.0",
                              isReadOnly: false
        )
    }
}
