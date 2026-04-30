//
//  AlarmGovernor.swift
//  chronometrixt
//
//  Created by Becket on 4/14/26.
//

import Foundation
import SwiftData

@Observable final class AlarmGovernor {
    var newAlarm: MetrixtTime = metric.cal.replaceComponents(time: MetrixtTime(date: nil), components: [.hour, .minute, .second], with: [5, 50, 50])
    var alarms: [MetrixtTime] = []
    var activeAlarms: [MetrixtAlarm] = []
    var alarmHour: Int = 5 { didSet { updateNewAlarm() } }
    var alarmMinute: Int = 50 { didSet { updateNewAlarm() } }
    var alarmSecond: Int = 50 { didSet { updateNewAlarm() } }
    private func updateNewAlarm() {
        newAlarm = metric.cal.replaceComponents(
            time: newAlarm,
            components: [.hour, .minute, .second],
            with: [alarmHour, alarmMinute, alarmSecond]
        )
    }
    
    
    var newTimer: MetrixtTimer = MetrixtTimer(duration: 0)
    var timers: [MetrixtTimer] = []
    var activeTimers: [MetrixtTimer] = []
    var timerHour: Int = 0 { didSet { updateNewTimer() }}
    var timerMinute: Int = 0 { didSet { updateNewTimer() } }
    var timerSecond: Int = 0 { didSet { updateNewTimer() } }
    private func updateNewTimer() {
        newTimer = MetrixtTimer(duration: (timerHour * 10_000) + (timerMinute * 100) + timerSecond)
    }
    
    var stopwatch: MetrixtStopwatch? = nil
    
    var mode: SmallTimeMode = .timer
    enum SmallTimeMode: Hashable { case timer, alarm, stopwatch }
        
    var ng: NotificationGovernor?
    var lam: LiveActivityManager = LiveActivityManager()
    
    
    func populate(data: [MetricAlarm], eternalNow: MetrixtTime) {
        stopwatch = MetrixtStopwatch(time: nil)
        for datum in data {
            if datum.type == .alarm { alarms.append(MetrixtTime(years: datum.metricYears, seconds: datum.metricSeconds)) }
            if datum.type == .timer { timers.append(MetrixtTimer(duration: datum.metricSeconds)) }
            if datum.type == .stopwatch { stopwatch = MetrixtStopwatch(time: MetrixtTime(years: datum.metricYears, seconds: datum.metricSeconds) ) }
        }
    }
    
    func setAlarm(data: [MetricAlarm], context: ModelContext, eternalNow: MetrixtTime, oldAlarm: MetrixtTime?) {
        var ta: MetrixtTime = oldAlarm ?? newAlarm

        if ta.seconds < eternalNow.seconds {
            let tomorrow = metric.cal.update(time: eternalNow, component: .day, byAdding: 1)
            ta = metric.cal.replaceComponents(time: tomorrow, components: [.hour, .minute, .second], with: [ta.hour, ta.minute, ta.second])
        }
        
        let alarm = MetrixtAlarm(deadline: ta, onComplete: { [weak self] deadline in
            self?.handleAlarmCompletion(deadline: deadline)
        })
        
        activeAlarms.insert(alarm, at: 0)
        alarms.removeAll(where: { $0.id == ta.id })
        if alarms.count + activeAlarms.count > 3 { alarms.removeLast() }
        
        if oldAlarm == nil { saveAlarm(data: data, context: context) }
        
        Task {
            try? await ng?.scheduleAlarm(id: alarm.alarm, triggerTime: ta)
        }
    }
    func saveAlarm(data: [MetricAlarm], context: ModelContext) {
        let allAlarms = data.filter { $0.type == .alarm }
        let metric = MetricAlarm(time: newAlarm, type: .alarm)
        context.insert(metric)
        while allAlarms.count > 3 { context.delete(allAlarms.last!) }
    }
    func dismissAlarm(alarm: MetrixtAlarm) {
        alarm.escapement?.invalidate()
        activeAlarms.removeAll(where: { $0.alarm == alarm.alarm })
        alarms.insert(alarm.deadline, at: 0)
        Task {
            ng?.cancelNotification(id: alarm.alarm)
        }
    }
    func handleAlarmCompletion(deadline: MetrixtTime) {
        alarms.insert(deadline, at: 0)
        activeAlarms.removeAll(where: { $0.deadline == deadline })
    }
    
    func setTimer(data: [MetricAlarm], context: ModelContext, eternalNow: MetrixtTime, oldTimer: MetrixtTimer?) {
        let tt = oldTimer ?? newTimer
        
        activeTimers.insert(MetrixtTimer(duration: tt.duration), at: 0)
        timers.removeAll(where: { $0.id == tt.id })
        if timers.count + activeTimers.count > 3 { timers.removeLast() }
        
        if oldTimer == nil { saveTimer(data: data, context: context) }
        
        Task {
            await lam.startTimerActivity(
                timerID: newTimer.id,
                duration: tt.duration,
                endTime: tt.toGregDeadline()
            )
            try? await ng?.scheduleTimer(id: tt.id, duration: tt.duration)
        }
    }
    func saveTimer(data: [MetricAlarm], context: ModelContext) {
        let allTimers = data.filter { $0.type == .timer }
        let timer = MetricAlarm(time: MetrixtTime(years: 0, seconds: newTimer.duration), type: .timer)
        context.insert(timer)
        while allTimers.count > 3 { context.delete(allTimers.last!) }
    }
    func cancelTimer(timer: MetrixtTimer) {
        timer.cancelTimer()
        timers.insert(timer, at: 0)
        activeTimers.removeAll(where: { $0.id == timer.id})
        ng?.cancelNotification(id: timer.id)
    }
    
    func toggleStopwatch(data: [MetricAlarm], context: ModelContext) {
        guard let stopwatch else { return }
        if stopwatch.isStopwatching {
            stopwatch.pause()
        } else {
            stopwatch.resume()
        }
        if stopwatch.metricSeconds == 0 { saveStopwatch(data: data, context: context) }
    }
    func resetStopwatch(data: [MetricAlarm], context: ModelContext) {
        guard let stopwatch else { return }
        stopwatch.reset()
        deleteStopwatch(data: data, context: context)
    }
    private func saveStopwatch(data: [MetricAlarm], context: ModelContext) {
        deleteStopwatch(data: data, context: context)
        context.insert(MetricAlarm(time: MetrixtTime(date: nil), type: .stopwatch))
    }
    private func deleteStopwatch(data: [MetricAlarm], context: ModelContext) {
        let existingStopwatches = data.filter { $0.type == .stopwatch }
        for stopwatch in existingStopwatches { context.delete(stopwatch) }
    }
    
}
