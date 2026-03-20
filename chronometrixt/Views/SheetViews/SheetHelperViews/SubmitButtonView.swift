//
//  SubmitButtonView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/19/26.
//

import SwiftUI

struct SubmitButtonView: View {
    var imageString: String
    var text: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: imageString)
                Text(text)
            }
            .font(.caption2)
            .bold()
            .foregroundColor(.primary)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.gray).opacity(0.5))
            .shadow(radius: 3)
        }
    }
}

#Preview {
    SubmitButtonView(imageString: "gear", text: "yo", action: { print("hi") })
}
