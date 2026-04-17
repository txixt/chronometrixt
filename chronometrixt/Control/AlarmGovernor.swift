//
//  AlarmGovernor.swift
//  chronometrixt
//
//  Created by Becket on 4/14/26.
//

import Foundation

@Observable final class AlarmGovernor {
    var alarmSeconds: Int = 0
    var isStopwatching: Bool = false
    var stopwatch: Int = 0
    var mode: SmallTimeMode = .timer
    enum SmallTimeMode: Hashable { case timer, alarm, stopwatch }
}
