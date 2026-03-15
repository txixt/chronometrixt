//
//  PortraitView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/31/25.
//

import SwiftUI

struct PortraitView: View {
    @Bindable var gov: Governor
    var body: some View {
        NavigationView {
            ZStack {
                
                CalendarScrollView(gov: gov)
                
                TimeControlView(gov: gov)
            }
            .monospaced()
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: {}) {
                    Image(systemName: "bell")
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

#Preview {
    PortraitView(gov: Governor())
}
