//
//  ControlView.swift
//  watchixt Watch App
//
//  Created by Becket Bowes on 1/5/26.
//

import SwiftUI

struct ControlView: View {
    @Binding var gov: WatchGovernor
    
    var body: some View {
        VStack {
            HStack {
                Button(action: switchBase) {
                    Text(gov.timeBase == .ten ? "φ" : "10")
                        .foregroundColor(.primary)
                        .bold()
                }
                Spacer()
            }
            Spacer()
        }
        .padding()
    }
    
    private func switchBase() {
        if gov.timeBase == .ten { gov.timeBase = .eleven }
        else { gov.timeBase = .ten }
    }
}

#Preview {
    ControlView(gov: .constant(WatchGovernor()))
}
