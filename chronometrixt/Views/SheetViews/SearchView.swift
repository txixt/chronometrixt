//
//  SearchView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 7/5/26.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @Bindable var gov: Governor
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            SheetHeaderView(gov: gov, title: "search", titleImage: "magnifyingglass")
            
            NavigationStack {
                if !sortedEvents.isEmpty {
                    ScrollView {
                        List {
                        if !titleResults.isEmpty {
                            HStack {
                                Text("events")
                                Spacer()
                            }
                            MetrixtSubdivider()
                            ForEach(titleResults) { event in
                                Text(event.title).monospaced()
                            }
                        }
                        if !locationResults.isEmpty {
                            HStack {
                                Text("places")
                                Spacer()
                            }
                            MetrixtSubdivider()
                            ForEach(locationResults) { locale in
                                Text(locale.title)
                            }
                        }
                        if !notesResults.isEmpty {
                            HStack {
                                Text("notes")
                                Spacer()
                            }
                            MetrixtSubdivider()
                            ForEach(notesResults) { notes in
                                Text(notes.title)
                            }
                            }
                        }
                        .searchable(text: $searchText, prompt: "search events")
                    }
                } else {
                    VStack(alignment: .leading) {
                        Text("if you had any events, this is where you would search for them. but you don't.")
                        Text("my bubs, make some events, and we'll go a searchin'!")
                    }
                }
            }
        }
        .monospaced()
        .padding()
    }
    
    private var sortedEvents: [MetricEvent] {
        gov.eventData.sorted {
            abs($0.utcStart.timeIntervalSinceNow) < abs($1.utcStart.timeIntervalSinceNow)
        }
    }
    private var titleResults: [MetricEvent] {
        if searchText.isEmpty {
            return sortedEvents
        } else {
            return sortedEvents.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    private var locationResults: [MetricEvent] {
        return sortedEvents.filter {
            $0.location.localizedCaseInsensitiveContains(searchText)
        }
    }
    private var notesResults: [MetricEvent] {
        return sortedEvents.filter {
            $0.notes.localizedCaseInsensitiveContains(searchText)
        }
    }
}

#Preview {
    let gov = Governor()
    SearchView(gov: gov)
}
