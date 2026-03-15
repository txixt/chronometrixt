//
//  ControlView.swift
//  watchixt Watch App
//
//  Created by Becket Bowes on 1/5/26.
//

import SwiftUI

//struct WatchControlView: View {
//    @Binding var gov: WatchGovernor
//    
//    var body: some View {
//        VStack {
//            HStack {
//                Text("10")
//                    .font(.system(size: 18, weight: .bold))
//                    .foregroundColor(.gray).opacity(0.3)
//                    .padding()
//                    .padding(.top, 20)
//                    .onTapGesture(count: 3) {
//                        switchBase()
//                    }
//                Spacer()
//            }
//            Spacer()
//        }
//    }
//    
//    private func switchBase() {
//        if gov.timeBase == .ten { gov.timeBase = .eleven }
//        else { gov.timeBase = .ten }
//    }
//}
//
//#Preview {
//    WatchControlView(gov: .constant(WatchGovernor()))
//}
