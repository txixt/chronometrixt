//
//  ErrorAlertView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/17/26.
//

import SwiftUI
import SwiftData

struct ErrorAlertView: View {
    @Bindable var gov: Governor
    
    var body: some View {
        GeometryReader { geometryReader in
            let geo = gov.geoSize ?? geometryReader.size
            ZStack {
                Color.gray.opacity(0.2).ignoresSafeArea()
                
                HStack{
                    Spacer()
                    VStack {
                        Spacer()
                        
                        VStack {
                            ZStack {
                                Divider()
                                Image(systemName: "ant")
                            }
                            
                            Spacer()
                            
                            Text(gov.alertTxt.isEmpty ? "oops. some random thing went wrong." : gov.alertTxt)
                            
                            Spacer()
                            
                            Button(action: { gov.alert = nil }) {
                                Image(systemName: "plus")
                                    .tint(.primary)
                                    .rotationEffect(Angle(degrees: 45))
                                    .shadow(color: .gray, radius: 3)
                                    .bold()
                            }
                        
                        }
                        .padding()
                        .monospaced()
                        .background(RoundedRectangle(cornerRadius: 30).fill(.background.opacity(0.9)))
                        .frame(width: geo.width * 0.5, height: geo.height * 0.5)
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
        gov.alertTxt = ""
        gov.alert = nil
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var context
    ErrorAlertView(gov: Governor())
}
