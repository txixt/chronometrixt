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
    var activeAlarms: [MetrixtAlarm] = []
    var newTimer: MetrixtTime? = nil
    var timers: [MetrixtTime] = []
    var activeTimers: [MetrixtTimer] = []
    var stopwatch: MetrixtStopwatch = MetrixtStopwatch()
    var alarmSeconds: Int = 0
    
    var mode: SmallTimeMode = .timer
    enum SmallTimeMode: Hashable { case timer, alarm, stopwatch }
    
    func populate(data: [MetricAlarm], eternalNow: MetrixtTime) {
        newAlarm = metric.cal.replaceComponents(time: eternalNow, components: [.hour, .minute, .second], with: [5, 50, 50])
        newTimer = metric.cal.replaceComponents(time: eternalNow, components: [.hour, .minute, .second], with: [0, 0, 0])
        stopwatch = MetrixtStopwatch()
        for datum in data {
            let metrixt = MetrixtTime(years: datum.metricYears, seconds: datum.metricSeconds)
            if datum.type == "alarm" { alarms.append(metrixt) }
            if datum.type == "timer" { timers.append(metrixt) }
        }
    }
    
    func setAlarm(data: [MetricAlarm], context: ModelContext, eternalNow: MetrixtTime, alarmIndex: Int?) {
        guard (newAlarm != nil) else { return }
        var ta: MetrixtTime = alarmIndex == nil ? newAlarm! : alarms[alarmIndex!]
        if ta.seconds > eternalNow.seconds {
            ta = metric.cal.replaceComponents(time: eternalNow, components: [.hour, .minute, .second], with: [ta.hour, ta.minute, ta.second])
        }
        //set system Alarm
        
        activeAlarms.insert(MetrixtAlarm(deadline: ta), at: 0)
        alarms.removeAll(where: { $0.id == ta.id })
        if alarmIndex == nil { saveAlarm(data: data, context: context) }
    }
    func saveAlarm(data: [MetricAlarm], context: ModelContext) {
        let allAlarms = data.filter { $0.type == "alarm" }
        while allAlarms.count >= 3 { context.delete(allAlarms.last!) }
        let metrixt = MetricAlarm(metricTime: newAlarm, dataType: "alarm")
        context.insert(metrixt)
    }
    func handleAlarmCompletion(deadline: MetrixtTime) {
        alarms.insert(deadline, at: 0)
        activeAlarms.removeAll(where: { $0.deadline == deadline })
        
        //play music, display options etcetery
        
    }
    
    func setTimer(data: [MetricAlarm], context: ModelContext, eternalNow: MetrixtTime, timerIndex: Int?) {
        guard newTimer != nil else { return }
        let tt = timerIndex == nil ? newTimer! : timers[timerIndex!]
        activeTimers.insert(MetrixtTimer(time: tt), at: 0)
        //set system Alarm
        
        if timerIndex != nil { saveTimer(data: data, context: context) }
    }
    func saveTimer(data: [MetricAlarm], context: ModelContext) {
        let allTimers = data.filter { $0.type == "alarm" }
        while allTimers.count >= 3 { context.delete(allTimers.last!) }
        let metrixt = MetricAlarm(metricTime: newTimer, dataType: "timer")
        context.insert(metrixt)
    }
    func handleTimerCompletion(deadline: MetrixtTime) {
        alarms.insert(deadline, at: 0)
        activeAlarms.removeAll(where: { $0.deadline.id == deadline.id })
        
        //play music, display options, etcetery et etcetery ad nauseum
    }
    
}
