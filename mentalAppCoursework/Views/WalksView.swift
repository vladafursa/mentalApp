

//
//  WalksView.swift
//  mobile_implementation_coursework
//
//  Created by Влада Фурса on 30.01.25.
//

import GoogleMaps
import MapKit
import SwiftUI

struct GoogleMapView: UIViewRepresentable {
    // parameter variables
    let routes: [[CLLocationCoordinate2D]]
    let selectedRoute: [CLLocationCoordinate2D]
    // internal usage variables
    @ObservedObject private var locationManager = LocationManager()
    @State private var lastRoute: [CLLocationCoordinate2D] = []
    // create the first view
    func makeUIView(context _: Context) -> GMSMapView {
        // assign starting point to some place in Nottingham
        let camera = GMSCameraPosition.camera(withLatitude: 52.906, longitude: -1.230, zoom: 10.0)
        let mapView = GMSMapView(frame: UIScreen.main.bounds)
        // draw markers and directions for each route
        for route in routes {
            drawMarkers(mapView, route: route)
            for i in 0 ..< route.count {
                if i < route.count - 1 {
                    getDirection(mapView, start: route[i], end: route[i + 1])
                }
            }
        }
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        return mapView
    }

    // updates ui accordingly
    func updateUIView(_ mapView: GMSMapView, context _: Context) {
        // move camera to the current position
        if let location = locationManager.currentLocation {
            let cameraUpdate = GMSCameraUpdate.setTarget(location.coordinate)
            mapView.animate(with: cameraUpdate)
        }
        // if the route was chosen and is not the same as previous one, redraw
        if !selectedRoute.isEmpty {
            if !checkIfRoutesAreEqual(route1: selectedRoute, route2: lastRoute) {
                mapView.clear()
                lastRoute = selectedRoute
                drawMarkers(mapView, route: selectedRoute)
                Navigate(mapView, selectedRoute: selectedRoute)
            }
        }
    }

    // function that takes into account current location and adds it to the route
    func Navigate(_ mapView: GMSMapView, selectedRoute: [CLLocationCoordinate2D]) {
        guard let currentLocation = locationManager.currentLocation?.coordinate else { return }
        var selectedRoutWithCurrentLocation = selectedRoute
        selectedRoutWithCurrentLocation.insert(currentLocation, at: 0)
        for i in 0 ..< selectedRoutWithCurrentLocation.count {
            if i < selectedRoutWithCurrentLocation.count - 1 {
                getDirection(mapView, start: selectedRoutWithCurrentLocation[i], end: selectedRoutWithCurrentLocation[i + 1])
            }
        }
    }

    // draws markers for each coordinate of the route
    func drawMarkers(_ mapView: GMSMapView, route: [CLLocationCoordinate2D]) {
        for coordinate in route {
            let marker = GMSMarker(position: coordinate)
            marker.map = mapView
        }
    }

    // calculate the directions and draw them accordingly
    func getDirection(_ mapView: GMSMapView, start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        Task {
            // configuring request
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
            request.requestsAlternateRoutes = true
            request.transportType = .walking
            do {
                // exactly calculate the route(not just line, but exact direction route)
                let directions = try await MKDirections(request: request).calculate()
                if let calculatedRoute = directions.routes.first {
                    // draw these directions on a map
                    drawRouteDirections(mapView, route: calculatedRoute)
                }
            } catch {
                print("error calculating directions")
            }
        }
    }

    // draw provided data
    private func drawRouteDirections(_ mapView: GMSMapView, route: MKRoute) {
        let path = GMSMutablePath()
        for step in route.steps {
            path.add(step.polyline.coordinate)
        }
        DispatchQueue.main.async {
            // configure polyline and populate with data
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 3.0
            polyline.strokeColor = .blue
            // add poluline to the map
            polyline.map = mapView
        }
    }

    // check if 2 routes are the same by iterating through each pair of coordinates
    func checkIfRoutesAreEqual(route1: [CLLocationCoordinate2D], route2: [CLLocationCoordinate2D]) -> Bool {
        guard route1.count == route2.count else { return false }
        return zip(route1, route2).allSatisfy { coord1, coord2 in
            coord1.latitude == coord2.latitude && coord1.longitude == coord2.longitude
        }
    }
}

struct WalksView: View {
    // predefined routes
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
                            .font(.system(size: 22))
                            .foregroundColor(.textColour)
                            .padding(.top, 10)
                        HStack {
                            let routeDefinitions: [String: [CLLocationCoordinate2D]] = [
                                "Clifton": route1,
                                "Wollaton": route2,
                                "Daleside": route3,
                            ]
                            // drawing buttons
                            ForEach(routeDefinitions.keys.sorted(), id: \.self) { route in
                                Button(action: {
                                    // assigning selected route a value
                                    if let selectedValues = routeDefinitions[route], !selectedValues.isEmpty {
                                        selectedRoute = selectedValues
                                    }
                                }) {
                                    Text(route)
                                        .frame(maxWidth: .infinity)
                                        .padding(6)
                                        .foregroundColor(.white)
                                        .bold()
                                        .background(.buttonColour)
                                        .cornerRadius(7)
                                        .shadow(radius: 5)
                                }
                                .padding(.horizontal, 8)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    // parsing data to mapview
                    GoogleMapView(routes: routes, selectedRoute: selectedRoute)
                }
            }
        }
    }
}
