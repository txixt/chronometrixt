//
//  FunctionalScrollView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 1/13/26.
//
//
//import SwiftUI
//
//struct FunctionalScrollView: View {
//    @State var center: Int = 0
//    @State var centerStack: [Int] = []
//    @State private var scrollControl: CGFloat = 0
//
//    var body: some View {
//        LazyVStack {
//
//            if !centerStack.isEmpty {
//                ScrollView(.vertical) {
//                    VStack {
//                        ForEach(centerStack, id: \.self) { number in
//                            ZStack {
//                                Rectangle().frame(width: 100, height: 100).foregroundColor(.primary)
//                                Text("Cube #\(number)").foregroundColor(.white)
//                            }
//                        }
//                    }
//                }
//                .onScrollGeometryChange(for: CGFloat.self, of: { sg in sg.contentOffset.y }) { old, new in
//                    if abs(new - scrollControl) > 100 {
//                        center += new > old ? 1 : -1
//                        populateStack()
//                    }
//                }
//            }
//            
//        }
//        .onAppear() {
//            populateStack()
//        }
//    }
//
//    private func populateStack() {
//        var newStack: [Int] = []
//        for i in -10...10 {
//            let newInt: Int = (center) + i
//            newStack.append(newInt)
//        }
//        centerStack = newStack
//    }
//}

///Kinda works:
//struct FunctionalScrollView: View {
//    @State var center: Int = 0
//    @State var centerStack: [Int] = []
//    @State private var scrollControl: CGFloat = 0
//
//    var body: some View {
//        LazyVStack {
//
//            if !centerStack.isEmpty {
//                ScrollView(.vertical) {
//                    VStack {
//                        ForEach(centerStack, id: \.self) { number in
//                            ZStack {
//                                Rectangle().frame(width: 100, height: 100).foregroundColor(.primary)
//                                Text("Cube #\(number)").foregroundColor(.white)
//                            }
//                        }
//                    }
//                }
//                .onScrollGeometryChange(for: CGFloat.self) { scrollGeo in
//                    scrollGeo.contentOffset.y
//                } action: { _, newOffset in
//                    let offsetVariance = newOffset - scrollControl
//                    if abs(newOffset) > 100 {
//                        updateStack(newOffset: offsetVariance)
//                        scrollControl = newOffset
//                    }
//
//                }
//            }
//            
//        }
//        .onAppear() {
//            populateStack()
//        }
//    }
//
//    private func populateStack() {
//        var newStack: [Int] = []
//        for i in -10...10 {
//            let newInt: Int = (center) + i
//            newStack.append(newInt)
//        }
//        centerStack = newStack
//    }
//    
//    private func updateStack(newOffset: CGFloat) {
//        center += newOffset > 0 ? 1 : -1
//        populateStack()
//    }
//}
//
//#Preview {
//    FunctionalScrollView()
//}
