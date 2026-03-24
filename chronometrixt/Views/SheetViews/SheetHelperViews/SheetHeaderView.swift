//
//  SheetHeaderView.swift
//  chronometrixt
//
//  Created by Becket on 3/19/26.
//

import SwiftUI

struct SheetHeaderView: View {
    @Bindable var gov: Governor
    var title: String
    var titleImage: String
    
    var body: some View {
        HStack {
            Image(systemName: titleImage)
            Text(title)
            Spacer()
            Button(action: { gov.sheet = .none }) {
                Image(systemName: "plus")
                    .rotationEffect(Angle(degrees: 45))
                    .shadow(color: .gray, radius: 3)
            }
        }
        .font(.largeTitle.bold())
        .foregroundStyle(.primary)
        
        ZStack {
            RoundedRectangle(cornerRadius: 2.5).frame(width: 100, height: 5)
            Divider()
        }
        .padding(.bottom)
    }
}

#Preview {
    SheetHeaderView(gov: Governor(), title: "title", titleImage: "photo")
}
