

//
//  WalksView.swift
//  mobile_implementation_coursework
//
//  Created by Влада Фурса on 30.01.25.
//

import AVFoundation
import GoogleMaps
import MapKit
import SwiftUI

struct GoogleMapView: UIViewRepresentable {
    @ObservedObject private var locationManager = LocationManager()
    let routes: [[CLLocationCoordinate2D]]
    let selectedRoute: [CLLocationCoordinate2D]
    private let speechSynthesizer = AVSpeechSynthesizer()
    @State private var currentStepIndex = 0
    @State private var currentRouteSteps: [MKRoute.Step] = []
    @State private var lastRoute: [CLLocationCoordinate2D] = []
    let synthesizer = AVSpeechSynthesizer()
    func makeUIView(context _: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: 52.906, longitude: -1.230, zoom: 10.0)
        let mapView = GMSMapView(frame: UIScreen.main.bounds)

        for route in routes {
            drawMarkers(mapView, route: route)
            for i in 0 ..< route.count {
                if i < route.count - 1 {
                    getDirection(mapView, start: route[i], end: route[i + 1])
                }
            }
        }
        /* if let location = locationManager.currentLocation {
         print(location.coordinate)
         }*/

        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context _: Context) {
        if let location = locationManager.currentLocation {
            let cameraUpdate = GMSCameraUpdate.setTarget(location.coordinate)
            mapView.animate(with: cameraUpdate)
        }
        if !selectedRoute.isEmpty {
            if !checkIfRoutesAreEqual(route1: selectedRoute, route2: lastRoute) {
                mapView.clear()
                lastRoute = selectedRoute
                drawMarkers(mapView, route: selectedRoute)
                Navigate(mapView, selectedRoute: selectedRoute)
            }
        }
    }

    func Navigate(_ mapView: GMSMapView, selectedRoute: [CLLocationCoordinate2D]) {
        guard let currentLocation = locationManager.currentLocation?.coordinate else { return }
        var selectedRoutWithCurrentLocation = selectedRoute
        selectedRoutWithCurrentLocation.insert(currentLocation, at: 0)
        for i in 0 ..< selectedRoutWithCurrentLocation.count {
            if i < selectedRoutWithCurrentLocation.count - 1 {
                navigateUser(mapView, start: selectedRoutWithCurrentLocation[i], end: selectedRoutWithCurrentLocation[i + 1])
            }
        }
    }

    func drawMarkers(_ mapView: GMSMapView, route: [CLLocationCoordinate2D]) {
        for coordinate in route {
            let marker = GMSMarker(position: coordinate)
            marker.map = mapView
        }
    }

    func getDirection(_ mapView: GMSMapView, start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        Task {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
            request.requestsAlternateRoutes = true
            request.transportType = .walking
            do {
                let directions = try await MKDirections(request: request).calculate()
                if let calculatedRoute = directions.routes.first {
                    drawRouteDirections(mapView, route: calculatedRoute)
                }
            } catch {
                print("error calculating directions")
            }
        }
    }

    func navigateUser(_ mapView: GMSMapView, start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        Task {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
            request.requestsAlternateRoutes = true
            request.transportType = .walking
            do {
                let directions = try await MKDirections(request: request).calculate()
                if let calculatedRoute = directions.routes.first {
                    drawRouteDirections(mapView, route: calculatedRoute)
                    let instruction = calculatedRoute.steps.first?.instructions ?? "No instructions"
                    speakInstruction(comand: instruction)
                }
            } catch {
                print("error calculating directions")
            }
        }
    }

    private func drawRouteDirections(_ mapView: GMSMapView, route: MKRoute) {
        let path = GMSMutablePath()
        for step in route.steps {
            path.add(step.polyline.coordinate)
        }
        DispatchQueue.main.async {
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 3.0
            polyline.strokeColor = .blue
            polyline.map = mapView
        }
    }

    func checkIfRoutesAreEqual(route1: [CLLocationCoordinate2D], route2: [CLLocationCoordinate2D]) -> Bool {
        guard route1.count == route2.count else { return false }
        return zip(route1, route2).allSatisfy { coord1, coord2 in
            coord1.latitude == coord2.latitude && coord1.longitude == coord2.longitude
        }
    }

    func speakInstruction(comand: String) {
        let utterance = AVSpeechUtterance(string: comand)
        utterance.rate = 0.57
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.8
        let voice = AVSpeechSynthesisVoice(language: "en-EN")
        utterance.voice = voice
    }
}

struct WalksView: View {
    let route1: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 52.906, longitude: -1.230),
        CLLocationCoordinate2D(latitude: 52.902, longitude: -1.225),
        CLLocationCoordinate2D(latitude: 52.907, longitude: -1.234),
        CLLocationCoordinate2D(latitude: 52.906, longitude: -1.230),
    ]

    let route2: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 52.948, longitude: -1.204),
        CLLocationCoordinate2D(latitude: 52.950, longitude: -1.210),
        CLLocationCoordinate2D(latitude: 52.945, longitude: -1.216),
        CLLocationCoordinate2D(latitude: 52.948, longitude: -1.204),
    ]

    let route3: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 52.950, longitude: -1.111),
        CLLocationCoordinate2D(latitude: 52.947, longitude: -1.118),
        CLLocationCoordinate2D(latitude: 52.951, longitude: -1.118),
        CLLocationCoordinate2D(latitude: 52.950, longitude: -1.111),
    ]
    var routes: [[CLLocationCoordinate2D]] {
        return [route1, route2, route3]
    }

    @State private var selectedRoute: [CLLocationCoordinate2D] = []
    var body: some View {
        NavigationView {
            ZStack {
                Color("backgroundColour")
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    VStack {
                        Text("Choose the route you want to explore")
                        let routeDefinitions: [String: [CLLocationCoordinate2D]] = [
                            "Route1": route1,
                            "Route2": route2,
                            "Route3": route3,
                        ]

                        ForEach(routeDefinitions.keys.sorted(), id: \.self) { route in
                            Button(action: {
                                if let selectedValues = routeDefinitions[route], !selectedValues.isEmpty {
                                    selectedRoute = selectedValues
                                } else {
                                    print("No values found or empty array for \(route).")
                                }
                            }) {
                                Text(route)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(3)
                            }
                            .padding(.horizontal)
                        }
                    }
                    GoogleMapView(routes: routes, selectedRoute: selectedRoute)
                }
            }
        }
    }
}

#Preview {
    WalksView()
}
