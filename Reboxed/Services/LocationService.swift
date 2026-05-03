/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Thomas Grossen
 ******************************************************************************/

import CoreLocation
import Observation

@Observable
final class LocationService: NSObject, CLLocationManagerDelegate
{
    var currentLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let manager = CLLocationManager()
    static let movedThresholdMeters: CLLocationDistance = 500

    override init()
    {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation()
    {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func distance( to house: House ) -> CLLocationDistance?
    {
        guard house.hasCoordinates, let loc = currentLocation else { return nil }
        let houseLoc = CLLocation( latitude: house.latitude, longitude: house.longitude )
        return loc.distance( from: houseLoc )
    }

    func isFarFrom( house: House ) -> Bool
    {
        guard let d = distance( to: house ) else { return false }
        return d > Self.movedThresholdMeters
    }

    func locationManager( _ manager: CLLocationManager, didUpdateLocations locations: [ CLLocation ] )
    {
        currentLocation = locations.last
    }

    func locationManager( _ manager: CLLocationManager, didFailWithError error: Error ) {}

    func locationManagerDidChangeAuthorization( _ manager: CLLocationManager )
    {
        authorizationStatus = manager.authorizationStatus
        #if os(iOS)
        if manager.authorizationStatus == .authorizedWhenInUse
        {
            manager.requestLocation()
        }
        #else
        if manager.authorizationStatus == .authorizedAlways
        {
            manager.requestLocation()
        }
        #endif
    }
}
