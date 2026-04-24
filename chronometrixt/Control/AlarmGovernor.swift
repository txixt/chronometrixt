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
    
    var alarmHour: Int = 5 { didSet { updateNewAlarm() } }
    var alarmMinute: Int = 50 { didSet { updateNewAlarm() } }
    var alarmSecond: Int = 50 { didSet { updateNewAlarm() } }
    var timerHour: Int = 0 { didSet { updateNewTimer() }}
    var timerMinute: Int = 0 { didSet { updateNewTimer() } }
    var timerSecond: Int = 0 { didSet { updateNewTimer() } }
    
    var mode: SmallTimeMode = .timer
    enum SmallTimeMode: Hashable { case timer, alarm, stopwatch }
    
    private func updateNewAlarm() {
        guard let current = newAlarm else { return }
        newAlarm = metric.cal.replaceComponents(
            time: current,
            components: [.hour, .minute, .second],
            with: [alarmHour, alarmMinute, alarmSecond]
        )
    }
    
    private func updateNewTimer() {
        guard let current = newAlarm else { return }
        newTimer = metric.cal.replaceComponents(
            time: current,
            components: [.hour, .minute, .second],
            with: [timerHour, timerMinute, timerSecond]
        )
    }
    
    func populate(data: [MetricAlarm], eternalNow: MetrixtTime) {
        newAlarm = metric.cal.replaceComponents(time: eternalNow, components: [.hour, .minute, .second], with: [5, 50, 50])
        alarmHour = 5
        alarmMinute = 50
        alarmSecond = 50
        newTimer = metric.cal.replaceComponents(time: eternalNow, components: [.hour, .minute, .second], with: [0, 0, 0])
        stopwatch = MetrixtStopwatch()
        for datum in data {
            let metrixt = MetrixtTime(years: datum.metricYears, seconds: datum.metricSeconds)
            if datum.type == "alarm" { alarms.append(metrixt) }
            if datum.type == "timer" { timers.append(metrixt) }
        }
    }
    
    func setAlarm(data: [MetricAlarm], context: ModelContext, eternalNow: MetrixtTime, oldAlarm: MetrixtTime?) {
        guard newAlarm != nil else { return }
        var ta: MetrixtTime = oldAlarm ?? newAlarm!

        if ta.seconds < eternalNow.seconds {
            let tomorrow = metric.cal.update(time: eternalNow, component: .day, byAdding: 1)
            ta = metric.cal.replaceComponents(time: tomorrow, components: [.hour, .minute, .second], with: [ta.hour, ta.minute, ta.second])
        }
        
        let alarm = MetrixtAlarm(deadline: ta, onComplete: { [weak self] deadline in
            self?.handleAlarmCompletion(deadline: deadline)
        })
        
        activeAlarms.insert(alarm, at: 0)
        alarms.removeAll(where: { $0.id == ta.id })
        
        if oldAlarm == nil {
            saveAlarm(data: data, context: context)
        }
    }
    func saveAlarm(data: [MetricAlarm], context: ModelContext) {
        while alarms.count >= 3 { alarms.removeLast() }
        let allAlarms = data.filter { $0.type == "alarm" }
        while allAlarms.count >= 3 { context.delete(allAlarms.last!) }
        let metrixt = MetricAlarm(metricTime: newAlarm, dataType: "alarm")
        context.insert(metrixt)
    }
    func dismissAlarm(alarm: MetrixtAlarm) {
        alarm.escapement?.invalidate()
        activeAlarms.removeAll(where: { $0.alarm == alarm.alarm })
        alarms.insert(alarm.deadline, at: 0)
    }
    func handleAlarmCompletion(deadline: MetrixtTime) {
        alarms.insert(deadline, at: 0)
        activeAlarms.removeAll(where: { $0.deadline == deadline })
        
        //play music, display options etcetery
    }
    
    
    func setTimer(data: [MetricAlarm], context: ModelContext, eternalNow: MetrixtTime, oldTimer: MetrixtTime?) {
        guard newTimer != nil else { return }
        let tt = oldTimer == nil ? newTimer! : oldTimer!
        activeTimers.insert(MetrixtTimer(time: tt), at: 0)
        //set system Alarm
        
        if oldTimer != nil { saveTimer(data: data, context: context) }
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
