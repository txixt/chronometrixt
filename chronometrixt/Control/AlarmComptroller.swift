//
//  AlarmGovernor.swift
//  chronometrixt
//
//  Created by Becket on 4/14/26.
//

import Foundation
import SwiftData

@Observable final class AlarmComptroller {
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
    
    var gov: Governor
    var lam: LiveActivityManager = LiveActivityManager()
    
    init(gov: Governor) {
        self.gov = gov
    }
    
    func populate() {
        stopwatch = MetrixtStopwatch(time: nil)
        let allAlarms = gov.alarmData.filter({ $0.type == .alarm })
        while allAlarms.count > 3 { gov.context?.delete(allAlarms.last!) }
        let allTimers = gov.alarmData.filter({ $0.type == .timer })
        while allTimers.count > 3 { gov.context?.delete(allTimers.last!) }
        for datum in gov.alarmData {
            if datum.type == .alarm { alarms.append(MetrixtTime(years: datum.metricYears, seconds: datum.metricSeconds)) }
            if datum.type == .timer { timers.append(MetrixtTimer(duration: datum.metricSeconds)) }
            if datum.type == .stopwatch { stopwatch = MetrixtStopwatch(time: MetrixtTime(years: datum.metricYears, seconds: datum.metricSeconds) ) }
        }
    }
    
    func setAlarm(oldAlarm: MetrixtTime?) {
        guard let context = gov.context else { return }
        var ta: MetrixtTime = oldAlarm ?? newAlarm
        if ta.seconds < gov.eternalNow.time.seconds {
            let tomorrow = metric.cal.update(time: gov.eternalNow.time, component: .day, byAdding: 1)
            ta = metric.cal.replaceComponents(time: tomorrow, components: [.hour, .minute, .second], with: [ta.hour, ta.minute, ta.second])
        }
        
        let alarm = MetrixtAlarm(deadline: ta)
        
        activeAlarms.insert(alarm, at: 0)
        alarms.removeAll(where: { $0.id == ta.id })
        if alarms.count + activeAlarms.count > 3 { alarms.removeLast() }
        
        let dataId = oldAlarm == nil ?
        saveAlarm(data: gov.alarmData, context: context)
        :
        gov.alarmData.first(where: { $0.type == .alarm && $0.id == oldAlarm!.id })!.id
        
        Task {
            try? await NotificationAgent.shared.scheduleAlarm(id: alarm.id, dataId: dataId, triggerTime: ta)
        }
    }
    func saveAlarm(data: [MetricAlarm], context: ModelContext) -> String {
        let allAlarms = data.filter { $0.type == .alarm }
        let metric = MetricAlarm(id: newAlarm.id, time: newAlarm, type: .alarm)
        context.insert(metric)
        while allAlarms.count > 3 { context.delete(allAlarms.last!) }
        
        return metric.id
    }
    func dismissAlarm(id: String) {
        if let alarm = activeAlarms.first(where: { $0.id == id }) {
            alarm.escapement?.invalidate()
            activeAlarms.removeAll(where: { $0.id == alarm.id })
            alarms.insert(alarm.deadline, at: 0)
            Task {
                NotificationAgent.shared.cancelNotification(id: alarm.id)
            }
        }
    }
    func destroyAlarm(alarm: MetrixtTime) {
        guard let context = gov.context else { return }
        if let datum = gov.alarmData.first(where: { $0.type == .alarm && $0.metricSeconds == alarm.seconds }) {
            context.delete(datum)
            print("alarm deleted")
            alarms.removeAll(where: { $0.id == alarm.id })
        }
    }
    
    func setTimer(oldTimer: MetrixtTimer?) {
        guard let context = gov.context else { return }
        let tt = oldTimer ?? newTimer
        
        activeTimers.insert(MetrixtTimer(duration: tt.duration), at: 0)
        timers.removeAll(where: { $0.id == tt.id })
        if timers.count + activeTimers.count > 3 { timers.removeLast() }
        
        let dataId = oldTimer == nil ? saveTimer(id: newTimer.id, data: gov.alarmData, context: context)
        : gov.alarmData.first(where: { $0.type == .timer && $0.metricSeconds == oldTimer!.duration })!.id
        
        Task {
            await lam.startTimerActivity(
                timerID: newTimer.id,
                duration: tt.duration,
                endTime: tt.toGregDeadline()
            )
            try? await NotificationAgent.shared.scheduleTimer(id: tt.id, dataId: dataId, duration: tt.duration)
        }
    }
    func saveTimer(id: String, data: [MetricAlarm], context: ModelContext) -> String {
        let allTimers = data.filter { $0.type == .timer }
        let timer = MetricAlarm(id: id, time: MetrixtTime(years: 0, seconds: newTimer.duration), type: .timer)
        context.insert(timer)
        while allTimers.count > 3 { context.delete(allTimers.last!) }
        return timer.id
    }
    func cancelTimer(timer: MetrixtTimer) {
        timer.cancelTimer()
        timers.insert(timer, at: 0)
        activeTimers.removeAll(where: { $0.id == timer.id})
        NotificationAgent.shared.cancelNotification(id: timer.id)
    }
    func retireTimer(id: String) {
        if let timer = activeTimers.first(where: { $0.id == id }) {
            timers.insert(timer, at: 0)
            activeTimers.removeAll(where: { $0.id == id })
        }
    }
    func destroyTimer(timer: MetrixtTimer) {
        guard let context = gov.context else { return }
        if let datum = gov.alarmData.first(where: { $0.type == .timer && $0.metricSeconds == timer.duration }) {
            context.delete(datum)
            timers.removeAll(where: { $0.id == timer.id})
        }
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
        context.insert(MetricAlarm(id: stopwatch?.id ?? UUID().uuidString ,time: MetrixtTime(date: nil), type: .stopwatch))
    }
    private func deleteStopwatch(data: [MetricAlarm], context: ModelContext) {
        let existingStopwatches = data.filter { $0.type == .stopwatch }
        for stopwatch in existingStopwatches { context.delete(stopwatch) }
    }
    
}
