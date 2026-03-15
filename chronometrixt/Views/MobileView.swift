//
//  MobileView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/30/25.
//

import SwiftUI

struct MobileView: View {
    @Bindable var gov: Governor
    
    var body: some View {
        GeometryReader { geo in
            if geo.size.width > geo.size.height {
                VStack {
                    Spacer()
                    LandscapeView(gov: gov)
                    Spacer()
                }
            } else {
                PortraitView(gov: gov)
            }
        }
    }
}

#Preview {
    MobileView(gov: Governor())
}
