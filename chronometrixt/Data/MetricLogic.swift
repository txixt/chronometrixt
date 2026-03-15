//
//  MetricLogic.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/31/25.
//

import Foundation

struct MetricLogic {
    static let months: [String] = ["Nonth", "Wonth", "Toonth", "Trenth"]
    static let weeks: [String] = ["Nonek", "Wonek", "Toonek", "Trenek", "Fornek", "Finek", "Sixnek", "Sevnek", "Aynek", "Nynek"]
    static let days: [String] = ["Nondy", "Wondy", "Toody", "Tredy", "Fordy", "Fidy", "Sixdy", "Sevdy", "Aidy", "Nindy"]
    static let hours: [String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    static let monthRange: [Int] = Array(months.indices)
    static let weekRange: [Int] = Array(weeks.indices)
    static let dayRange: [Int] = Array(days.indices)
    static let hourRange: [Int] = Array(hours.indices)
}
