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
    @State private var didSearch: Bool = false
    
    var body: some View {
        VStack {
            Group {
                if let mapItem {
                    let coordinate = mapItem.location.coordinate
                    Map(position: $cameraPosition) {
                        Marker(mapItem.name ?? location, coordinate: coordinate)
                    }
                    .labelsHidden()
//                    .mapStyle(.standard(elevation: .flat))
                    .mapStyle(.imagery(elevation: .realistic))
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .opacity(0.5)
                } else if didSearch {
                    EmptyView()
                }
            }
        }
        .onAppear { print("this exists now. ")}
        .task(id: location) {
            let trimmed = location.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                print("trimmed is empty")
                mapItem = nil
                didSearch = false
                return
            }

            mapItem = nil
            didSearch = false

            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = trimmed
            let search = MKLocalSearch(request: request)
            print(request)

            do {
                let response = try await search.start()
                if let first = response.mapItems.first {
                    mapItem = first
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: first.location.coordinate,
                            latitudinalMeters: 10000,
                            longitudinalMeters: 10000
                        )
                    )
                }
            } catch {
                print("no mudville in joy")
            }
            didSearch = true
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
