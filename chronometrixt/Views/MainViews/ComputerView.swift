//
//  ComputerView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/30/25.
//

import SwiftUI
import SwiftData

struct ComputerView: View {
    @Bindable var gov: Governor
    
    var body: some View {
        MetricClockView(gov: gov, scale: 4.0)
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var context
    ComputerView(gov: Governor())
}
