//
//  ComputerView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/30/25.
//

import SwiftUI

struct ComputerView: View {
    @Bindable var gov: Governor
    
    var body: some View {
        MetricClockView(gov: gov, scale: 4.0)
    }
}

#Preview {
    ComputerView(gov: Governor())
}
