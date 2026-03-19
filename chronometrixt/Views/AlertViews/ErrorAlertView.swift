//
//  ErrorAlertView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/17/26.
//

import SwiftUI

struct ErrorAlertView: View {
    @Bindable var gov: Governor
    
    var body: some View {
        if !gov.errorMessage.isEmpty {
            GeometryReader { geo in
                ZStack {
                    RoundedRectangle(cornerRadius: 30).fill(.background)
                    VStack {
                        Spacer()
                        ZStack {
                            Divider()
                            Image(systemName: "ant")
                                .font(.largeTitle)
                        }
                        Spacer()
                        
                        Text(gov.errorMessage)
                        
                        Button(action: { gov.alert = nil }) {
                            Image(systemName: "plus")
                                .rotationEffect(Angle(degrees: 45))
                                .bold()
                        }
                    }
                    .padding()
                }
                .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.5)
                .task { await lifeIsShort() }
            }
        }
    }
    
    private func lifeIsShort() async {
        try? await Task.sleep(for: .seconds(2))
        gov.alert = nil
    }
}

#Preview {
    ErrorAlertView(gov: Governor())
}
