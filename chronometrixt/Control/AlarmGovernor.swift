//
//  AlarmGovernor.swift
//  chronometrixt
//
//  Created by Becket on 4/14/26.
//

import Foundation

@Observable final class AlarmGovernor {
    var mode: SmallTimeMode = .timer
    enum SmallTimeMode { case timer, alarm, stopwatch }
    
}
