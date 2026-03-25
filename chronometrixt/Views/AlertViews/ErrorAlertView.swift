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
        GeometryReader { geo in
            ZStack {
                HStack{
                    Spacer()
                    VStack {
                        Spacer()
                        
                        
                        VStack {
                            Spacer()
                            ZStack {
                                Divider()
                                Image(systemName: "ant")
                                    .font(.largeTitle)
                            }
                            
                            Spacer()
                            
                            Text(gov.errorMessage.isEmpty ? "oops. some random thing went wrong." : gov.errorMessage)
                            
                            Spacer()
                            
                            Button(action: { gov.alert = nil }) {
                                Image(systemName: "plus")
                                    .tint(.primary)
                                    .rotationEffect(Angle(degrees: 45))
                                    .shadow(color: .gray, radius: 3)
                                    .bold()
                            }
                            
                            
                            
                            Spacer()
                        }
                        .padding()
                        .monospaced()
                        .background(RoundedRectangle(cornerRadius: 30).fill(.background.opacity(0.9)))
                        .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.5)
                        .task { await lifeIsShort() }
        
                        
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
    
    private func lifeIsShort() async {
        try? await Task.sleep(for: .seconds(2))
        gov.errorMessage = ""
        gov.alert = nil
    }
}

#Preview {
    ErrorAlertView(gov: Governor())
}
