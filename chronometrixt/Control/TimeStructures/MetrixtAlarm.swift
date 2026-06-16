//
//  MetrixtAlarm.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/28/26.
//

import Foundation

@Observable final class MetrixtAlarm: Identifiable {
    var id: String
    var deadline: MetrixtTime
    var countdown: Int
    var escapement: Timer?
    private var onComplete: ((MetrixtTime) -> Void)?
    
    init(deadline: MetrixtTime, onComplete: ((MetrixtTime) -> Void)? = nil) {
        self.id = UUID().uuidString
        self.deadline = deadline
        self.countdown = deadline.seconds - MetrixtTime(date: nil).seconds
        self.onComplete = onComplete
        escapement = Timer.scheduledTimer(withTimeInterval: 0.864, repeats: true) { [weak self] _ in
            guard let self else { return }
            startAlarm()
        }
    }
    
    func startAlarm() {
        countdown -= 1
        if countdown <= 0 {
            endAlarm()
        }
    }
    
    func endAlarm() {
        escapement?.invalidate()
        escapement = nil
        onComplete?(deadline)
    }
    
    deinit {
        escapement?.invalidate()
        escapement = nil
    }
}
extension MetrixtAlarm: CustomStringConvertible {
    var description: String { return deadline.hourMinuteSecondTxt }
    var countdownTxt: String { return String(format: "%01d:%02d:%02d", countdown/10_000, (countdown/100)%100, countdown%100) }
}
