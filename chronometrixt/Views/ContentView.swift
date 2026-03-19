//
//  ContentView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/30/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.scenePhase) private var scene
//    @Environment(\.modelContext) private var context
    @Query private var items: [MetricEvent]
    @State var gov: Governor = Governor()
    
    var body: some View {
        ZStack {
#if os(iOS)
            MobileView(gov: gov)
#endif
#if os(macOS)
            ComputerView(gov: gov)
#endif
        }
        .onChange(of: scene) { _, new in
            if new == .background || new == .inactive {
                gov.eternalNow.killTimer()
            } else {
                gov.eternalNow.restartTimer()
            }
        }
    }
}

#Preview {
    ContentView()
//        .modelContainer(for: MetricEvent.self, inMemory: true)
}

//#if os(watchOS)
//        WatchView(gov: $gov)
//#endif
//
        //        NavigationSplitView {
        //            List {
        //                ForEach(items) { item in
        //                    NavigationLink {
        //                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
        //                    } label: {
        //                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
        //                    }
        //                }
        //                .onDelete(perform: deleteItems)
        //            }
        //#if os(macOS)
        //            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        //#endif
        //            .toolbar {
        //#if os(iOS)
        //                ToolbarItem(placement: .navigationBarTrailing) {
        //                    EditButton()
        //                }
        //#endif
        //                ToolbarItem {
        //                    Button(action: addItem) {
        //                        Label("Add Item", systemImage: "plus")
        //                    }
        //                }
        //            }
        //        } detail: {
        //            Text("Select an item")
        //        }
        //    }
        //
        //    private func addItem() {
        //        withAnimation {
        //            let newItem = Item(timestamp: Date())
        //            modelContext.insert(newItem)
        //        }
        //    }
        //
        //    private func deleteItems(offsets: IndexSet) {
        //        withAnimation {
        //            for index in offsets {
        //                modelContext.delete(items[index])
        //            }
        //        }
        //    }
