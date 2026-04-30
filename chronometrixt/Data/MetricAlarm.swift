//
//  MetricAlarm.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/17/26.
//

import Foundation
import SwiftData

@Model final class MetricAlarm {
    ///for Events, metric and greg time represent alarm date - events can have multiple alarms, no snooze functionality
    ///for Alarms, metric and greg time represent alarm date - alarms are one off and alarm handler creates a new alarm on snooze. UX  limits alarms to 3 total
    ///for Timers, metric years can be ignored, metric seconds represents timer duration, and gregDate is the alarm time set for the system. UX limits timers to 3 total
    ///for Stopwatch, metric and greg time both represent initiation time. UX limits stopwatch to one.
    var id: String = UUID().uuidString
    var metricYears: Int
    var metricSeconds: Int
    var gregDate: Date
    private var typeString: String
    var type: AlarmType {
        get { AlarmType(rawValue: typeString) ?? .event }
        set { typeString = newValue.rawValue }
    }
    enum AlarmType: String, Codable, Sendable { case event, alarm, timer, stopwatch }
        
    init(time: MetrixtTime, type: AlarmType) {
        metricYears = time.years
        metricSeconds = time.seconds
        gregDate = time.toGreg()
        typeString = type.rawValue
        self.type = type
    }
    
    init(time: MetrixtTime, typeString: String) {
        metricYears = time.years
        metricSeconds = time.seconds
        gregDate = time.toGreg()
        self.typeString = typeString //"event", "alarm", "timer", "stopwatch"
    }
    
    func isActive() -> Bool { return gregDate > .now } ///for Events and Alarms and Timers, ignore for Stopwatch.
}
