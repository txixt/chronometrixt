//
//  MetrixtEnropy.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/28/26.
//

import Foundation

@Observable final class MetrixtEntropy: Equatable {
    var time: MetrixtTime
    private var escapement: Timer?
    
    init() {
        self.time = MetrixtTime(date: nil)
        escapement = Timer.scheduledTimer(withTimeInterval: 0.864, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.update()
        }
    }
    
    private func update() {
        time = time.seconds % 1000 == 0 ? MetrixtTime(date: nil) : metric.cal.update(time: time, component: .second, byAdding: 1)
    }
    
    func killTimer() { escapement?.invalidate(); escapement = nil }
    
    func restartTimer() {
        killTimer()
        time = MetrixtTime(date: nil)
        escapement = Timer.scheduledTimer(withTimeInterval: 0.864, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.update()
        }
    }
    
    deinit {
        escapement?.invalidate()
        escapement = nil
    }
    
    static func == (lhs: MetrixtEntropy, rhs: MetrixtEntropy) -> Bool {
        return lhs === rhs
    }
}
