//
//  MetrixtTimer.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/28/26.
//

import Foundation

@Observable final class MetrixtTimer: Identifiable {
    var id: String
    var duration: Int
    var deadline: Int
    var countdown: Int
    private var escapement: Timer?
    
    init(duration: Int) {
        self.id = UUID().uuidString
        self.duration = duration
        deadline = MetrixtTime(date: nil).hms + duration
        countdown = duration
        escapement = Timer.scheduledTimer(withTimeInterval: 0.864, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.updateTimer()
        }
    }
    
//    init(duration: Int, onComplete: ((MetrixtTimer) -> Void)? = nil) {
//        self.id = UUID().uuidString
//        self.duration = duration
//        self.onComplete = onComplete
//        deadline = MetrixtTime(date: nil).hms + duration
//        countdown = duration
//        escapement = Timer.scheduledTimer(withTimeInterval: 0.864, repeats: true) { [weak self] _ in
//            guard let self else { return }
//            self.updateTimer()
//        }
//    }
    
    private func updateTimer() {
        countdown -= 1
        if countdown <= 0 {
            escapement?.invalidate()
            escapement = nil
            //completion handler
        }
    }
    
    func cancelTimer() {
        escapement?.invalidate()
        escapement = nil
    }
    
    func toGregDeadline() -> Date {
        return Date.now.addingTimeInterval(TimeInterval(duration))
    }

    deinit {
        escapement?.invalidate()
        escapement = nil
    }
}
extension MetrixtTimer {
    var totalSeconds: Double { TimeInterval(Double(duration % 100_000) * 0.864) }
    var hours: Int { (duration / 10_000) % 10 }
    var minutes: Int { (duration / 100) % 100 }
    var seconds: Int { duration % 100 }
    var countdownHr: Int { (countdown / 10_000) % 10 }
    var countdownMin: Int { (countdown / 100) % 100 }
    var countdownSec: Int { countdown % 100 }
    var gregHr: Int { Int(totalSeconds) / 3600 }
    var gregMin: Int { (Int(totalSeconds) % 3600) / 60 }
    var gregSec: Int { Int(totalSeconds) % 60 }
}
extension MetrixtTimer: CustomStringConvertible {
    var description: String { String(duration) }
    var durationTxt: String { return String(format: "%01d:%02d:%02d", hours, minutes, seconds) }
    var countdownTxt: String { return String(format: "%01d:%02d:%02d", countdownHr, countdownMin, countdownSec)  }
    var gregDurationTxt: String { return String(format: "%02d:%02d:%02d", gregHr, gregMin, gregSec) }
}
//@Observable final class MetrixtTimer: Identifiable {
//    var id: String = UUID().uuidString
//    var deadline: MetrixtTime
//    var countdown: MetrixtTime
//    var pause: Bool = false
//    private var escapement: Timer?
//
//    init(time: MetrixtTime) {
//        let now = MetrixtTime(date: nil)
//        deadline = metric.cal.replaceComponents(
//            time: now,
//            components: [.year, .month, .week, .day],
//            with: [now.year, now.month, now.week, (time.hms > now.hms ? now.day + 1 : now.day)]
//        )
//        countdown = metric.cal.update(time: time, component: .second, byAdding: time.seconds - now.seconds)
//        escapement = Timer.scheduledTimer(withTimeInterval: 0.864, repeats: true) { [weak self] _ in
//            guard let self else { return }
//            self.update()
//        }
//    }
//
//    private func update() {
//        if !pause {
//            countdown = metric.cal.update(time: countdown, component: .second, byAdding: -1)
//        }
//        if countdown.seconds > deadline.seconds {
//            escapement?.invalidate()
//            escapement = nil
//        }
//    }
//
//    deinit {
//        escapement?.invalidate()
//        escapement = nil
//    }
//}
