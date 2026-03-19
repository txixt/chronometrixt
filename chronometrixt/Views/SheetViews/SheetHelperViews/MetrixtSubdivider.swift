//
//  MetrixtSubdivider.swift
//  chronometrixt
//
//  Created by Becket on 3/19/26.
//

import SwiftUI

struct MetrixtSubdivider: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 1.5).frame(width: 100, height: 3)
                .foregroundColor(.gray)
            Divider()
        }
        .padding(.bottom)
    }
}

#Preview {
    MetrixtSubdivider()
}
