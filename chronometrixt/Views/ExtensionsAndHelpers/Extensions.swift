//
//  Extensions.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/24/26.
//

import Foundation
import SwiftUI

extension Color {
    /// Create a Color from a hex string. Accepts "FF6B35", "#FF6B35", or "0xFF6B35".
    init(hex: String) {
        let cleaned = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "0x", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        
        self.init(red: r, green: g, blue: b)
    }
}
