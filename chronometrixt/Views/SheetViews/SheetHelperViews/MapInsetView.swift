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
            
            HStack {
                Text("at:")
                    .font(.caption)
                Spacer()
                
                if let mapItem {
                    let string = String(format: "%.6f, %.6f", mapItem.location.coordinate.latitude, mapItem.location.coordinate.longitude)
                    Button(action: { UIPasteboard.general.string = string; print(string) }) {
                        Image(systemName: "square.on.square")
                    }
                    .tint(.primary)
                    .shadow(color: .gray, radius: 3)
                }
            }
            
            ZStack {
                Group {
                    if let mapItem {
                        let coordinate = mapItem.location.coordinate
                        
                        ZStack {
                            Map(position: $cameraPosition) {
                                Marker(mapItem.name ?? location, coordinate: coordinate)
                            }
                            .labelsHidden()
                            .mapStyle(.imagery(elevation: .realistic))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .opacity(0.5)
                            .onTapGesture {
                                mapItem.openInMaps(launchOptions: [
                                    MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: coordinate),
                                    MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                                ])
                            }
                            
                            HStack {
                                Rectangle().frame(height: 0.5).opacity(0.5)
                            }
                            VStack {
                                Rectangle().frame(width: 0.5, height: 50).opacity(0.5)
                            }
                        }
                    } else if didSearch {
                        EmptyView()
                    }
                }
                VStack {
                    HStack() {
                        Text(location)
                        .font(.title2)
                        .padding(.leading)
                        Spacer()
                    }
                    Spacer()
                }
            }
            .frame(height: 150)
        }
        .monospaced()
        .task(id: location) {
            let trimmed = location.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                mapItem = nil
                didSearch = false
                return
            }

            mapItem = nil
            didSearch = false

            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = trimmed
            let search = MKLocalSearch(request: request)

            do {
                let response = try await search.start()
                if let first = response.mapItems.first {
                    mapItem = first
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: first.location.coordinate,
                            latitudinalMeters: 3000000,
                            longitudinalMeters: 3000000
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
