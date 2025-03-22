import AVFoundation
import Combine
import CoreLocation
import Foundation

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var locationManager: CLLocationManager
    @Published var currentLocation: CLLocation?
    override init() {
        locationManager = CLLocationManager() // initialisation
        super.init()
        locationManager.delegate = self // set class delegate to receive location updates
        locationManager.requestWhenInUseAuthorization() // Request permission
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // use highest possible accuracy
        locationManager.distanceFilter = 15 // update location every 15 metres
        locationManager.startUpdatingLocation() // Start updating location initially
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations:
        [CLLocation])
    { // retrieve the most recent location from array of locations
        guard let location = locations.last else { return }
        currentLocation = location // Update the current location
        print("Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
