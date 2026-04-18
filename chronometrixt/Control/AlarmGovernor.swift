//
//  AlarmGovernor.swift
//  chronometrixt
//
//  Created by Becket on 4/14/26.
//

import Foundation
import SwiftData

@Observable final class AlarmGovernor {
    var newAlarm: MetrixtTime? = nil
    var alarms: [MetrixtTime] = []
    var activeAlarms: [MetrixtEntropy] = []
    var newTimer: MetrixtTime? = nil
    var timers: [MetrixtTime] = []
    var activeTimers: [MetrixtEntropy] = []
    var newStopwatch: MetrixtTime? = nil
    
    var alarmSeconds: Int = 0
    var isStopwatching: Bool = false
    var stopwatch: Int = 0
    
    var mode: SmallTimeMode = .timer
    enum SmallTimeMode: Hashable { case timer, alarm, stopwatch }
    
    func populate(data: [MetricAlarm], eternalNow: MetrixtTime) {
        newAlarm = metric.cal.replace(time: eternalNow, component: .hour, with: 5)
        newAlarm = metric.cal.replace(time: newAlarm!, component: .minute, with: 50)
        newAlarm = metric.cal.replace(time: newAlarm!, component: .second, with: 50)
        newTimer = metric.cal.replace(time: eternalNow, component: .hour, with: 0)
        newTimer = metric.cal.replace(time: newTimer!, component: .minute, with: 0)
        newTimer = metric.cal.replace(time: newTimer!, component: .second, with: 0)
        newStopwatch = newTimer
        for datum in data {
            let metrixt = MetrixtTime(years: datum.metricYears, seconds: datum.metricSeconds)
            if datum.type == "alarm" { alarms.append(metrixt) }
            if datum.type == "timer" { timers.append(metrixt) }
        }
    }
    
    func setAlarm(data: [MetricAlarm], context: ModelContext, eternalNow: MetrixtTime) {
        guard (newAlarm != nil) else { return }
        if newAlarm!.seconds > eternalNow.seconds { newAlarm = metric.cal.update(time: newAlarm!, component: .day, byAdding: 1) }
        //set system Alarm
        saveAlarm(data: data, context: context)
    }
    func saveAlarm(data: [MetricAlarm], context: ModelContext) {
        let allAlarms = data.filter { $0.type == "alarm" }
        while allAlarms.count >= 3 { context.delete(allAlarms.last!) }
        let metrixt = MetricAlarm(metricTime: newAlarm, dataType: "alarm")
        context.insert(metrixt)
    }
    
    func setTimer(data: [MetricAlarm], context: ModelContext) {
        
    }
    func saveTimer(data: [MetricAlarm], context: ModelContext) {
        let allTimers = data.filter { $0.type == "alarm" }
        while allTimers.count >= 3 { context.delete(allTimers.last!) }
        let metrixt = MetricAlarm(metricTime: newTimer, dataType: "timer")
        context.insert(metrixt)
    }
}
