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

