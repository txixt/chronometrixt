//
//  MapInsetView.swift
//  chronometrixt
//
//  Created by Becket on 3/23/26.
//

import SwiftUI
import MapKit
struct MapInsetView: View {
    let location: String
 
    @State private var mapItem: MKMapItem?
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var searchTask: Task<Void, Never>?
    @State var didSearch: Bool = false
    
    var body: some View {
        Group {
            if let mapItem {
                Map(position: $cameraPosition) {
                    Marker(mapItem.name ?? location, coordinate: mapItem.location.coordinate)
                }
                .mapStyle(.standard(elevation: .flat))
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else if didSearch {
                EmptyView()
            }
        }
        .task(id: location) {
            let trimmed = location.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                mapItem = nil
                didSearch = false
                return
            }

            mapItem = nil
            didSearch = false

            searchTask?.cancel()
            searchTask = Task {
                guard !Task.isCancelled else { return }

                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = trimmed
                let search = MKLocalSearch(request: request)

                do {
                    let response = try await search.start()
                    if let first = response.mapItems.first {
                        await MainActor.run {
                            mapItem = first
                            cameraPosition = .region(
                                MKCoordinateRegion(
                                    center: first.location.coordinate,
                                    latitudinalMeters: 1000,
                                    longitudinalMeters: 1000
                                )
                            )
                            didSearch = true
                        }
                    } else {
                        await MainActor.run { didSearch = true }
                    }
                } catch {
                    await MainActor.run { didSearch = true }
                }
            }
        }
    }
}

#Preview {
    MapInsetView(location: "huntsville alabama")
}
//
//import SwiftUI
//import MapKit
//
//struct InsetLocationMap: View {
//    let locationQuery: String
//
//    @State private var mapItem: MKMapItem?
//    @State private var cameraPosition: MapCameraPosition = .automatic
//    @State private var searchTask: Task<Void, Never>?
//
//    var body: some View {
//        Group {
//            if let mapItem {
//                Map(position: $cameraPosition) {
//                    Marker(mapItem.name ?? locationQuery, coordinate: mapItem.location.coordinate)
//                }
//                .mapStyle(.standard) // .hybrid, .imagery
//                .frame(height: 180)
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//                .onAppear {
//                    cameraPosition = .region(
//                        MKCoordinateRegion(
//                            center: mapItem.placemark.coordinate,
//                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
//                        )
//                    )
//                }
//            }
//        }
//        .onChange(of: locationQuery) { _, newValue in
//            let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
//            guard !trimmed.isEmpty else {
//                mapItem = nil
//                return
//            }
//
//            searchTask?.cancel()
//            searchTask = Task {
//                try? await Task.sleep(nanoseconds: 350_000_000) // debounce
//                guard !Task.isCancelled else { return }
//
//                let request = MKLocalSearch.Request()
//                request.naturalLanguageQuery = trimmed
//                let search = MKLocalSearch(request: request)
//
//                do {
//                    let response = try await search.start()
//                    if let first = response.mapItems.first {
//                        await MainActor.run {
//                            mapItem = first
//                        }
//                    }
//                } catch {
//                    await MainActor.run {
//                        mapItem = nil
//                    }
//                }
//            }
//        }
//    }
//}
