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
    var metricYears: Int
    var metricSeconds: Int
    var gregDate: Date
    
    init(metricTime: MetrixtTime?, dataType: String) {
        let metric = metricTime ?? MetrixtTime(date: nil)
        id = UUID().uuidString
        type = dataType //alarm or timer
        metricYears = metric.years
        metricSeconds = metric.seconds
        gregDate = metric.toGreg()
    }
}
