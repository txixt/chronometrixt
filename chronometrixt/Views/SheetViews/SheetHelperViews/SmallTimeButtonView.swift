//
//  SmallTimeButtonView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/16/26.
//

import SwiftUI

struct SmallTimeButtonView: View {
    var imageString: String
    var text: String
    var action: () -> Void
    var color: Color
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: imageString)
                Text(text)
            }
            .foregroundStyle(.background)
            .font(.title2).bold()
            .frame(width: 110, height: 110)
            .background(RoundedRectangle(cornerRadius: 10).fill(color))
        }
    }
}

#Preview {
    SmallTimeButtonView(imageString: "gear", text: "sup", action: { print("punch a fascist for your mental health") }, color: .gray)
}
