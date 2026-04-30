//
//  MetrixtStopwatch.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/28/26.
//

import Foundation

@Observable final class MetrixtStopwatch {
    var metricSeconds: Int = 0
    var isStopwatching: Bool = false
    private var escapement: Timer? = nil
    
    init(time: MetrixtTime?) {
        metricSeconds = time == nil ? 0 : MetrixtTime(date: nil).seconds - time!.seconds
        escapement = Timer.scheduledTimer(withTimeInterval: 0.864, repeats: true) { [weak self] _ in
            guard let self, self.isStopwatching else { return }
            self.metricSeconds += 1
        }
    }
    
    func pause() {
        isStopwatching = false
    }
    
    func resume() {
        isStopwatching = true
    }
    
    func reset() {
        isStopwatching = false
        metricSeconds = 0
    }
    
    func killTimer() {
        escapement?.invalidate()
        escapement = nil
    }
    
    deinit {
        escapement?.invalidate()
        escapement = nil
    }
}
