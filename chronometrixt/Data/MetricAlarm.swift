//
//  MetricAlarm.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/17/26.
//

import Foundation
import SwiftData

@Model final class MetricAlarm {
    var id: String
    var type: String
    var metricYears: Int // for alarms should be time standard, for timers should be 0
    var metricSeconds: Int // for alarms should be time standard, for timers should be timer duration
    var gregDate: Date // for both alarms and timers this should represent the latest alarm notification deadline
    var isActive: Bool
    
    init(metricTime: MetrixtTime?, dataType: String, isActive: Bool) {
        let metric = metricTime ?? MetrixtTime(date: nil)
        id = UUID().uuidString
        type = dataType //alarm or timer
        metricYears = metric.years
        metricSeconds = metric.seconds
        gregDate = metric.toGreg()
        self.isActive = isActive
    }
}
