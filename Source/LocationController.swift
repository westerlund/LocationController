//
//  LocationController.swift
//  Nutrif.io
//
//  Created by Simon Westerlund on 26/01/15.
//  Copyright (c) 2015 Nutrif.io. All rights reserved.
//

import UIKit
import CoreLocation

public class LocationController: NSObject, CLLocationManagerDelegate {
    var didUpdateLocation: ((location: CLLocation) -> Void)?
    
    private let accuracy: Double = 150
    private let locationManager = CLLocationManager()
    private var cancellableBlock: dispatch_block_t?
    private var skipBlock = false
    private var locations:[CLLocation] = [CLLocation]() {
        didSet {
            if locations.count > 0 {
                let sortedLocations = sorted(locations, { (a, b) -> Bool in
                    return a.horizontalAccuracy < b.horizontalAccuracy
                })
                if sortedLocations[0].horizontalAccuracy <= self.accuracy {
                    if didFetchBestLocation != nil {
                        skipBlock = true
                        didFetchBestLocation!(location: sortedLocations[0])
                        didFetchBestLocation = nil
                        stopUpdatingLocation()
                    }
                }
            }
        }
    }
    private var didUpdateAuthorizationStatusBlock: ((status: CLAuthorizationStatus) -> ())?
    private var didFetchBestLocation: ((location: CLLocation) -> Void)?
    
    public class func hasGPSAccess() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case CLAuthorizationStatus.AuthorizedWhenInUse, CLAuthorizationStatus.AuthorizedAlways:
            return true
        default:
            return false
        }
    }
    
    public class func canRequestAccess() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case CLAuthorizationStatus.NotDetermined:
            return true
        default:
            return false
        }
    }
    
    public class func requestWhenInUseAccess() {
        LocationController.shared().locationManager.requestWhenInUseAuthorization()
    }
    
    public class func requestAlwaysAccess() {
        LocationController.shared().locationManager.requestAlwaysAuthorization()
    }
    
    public func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    public func startMonitoringSignificantLocationChanges() {
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    public func fetchBestLocationWithTimeout(timeout: Double, done: ((location: CLLocation) -> Void)) {
        skipBlock = false
        startUpdatingLocation()
        locations = [CLLocation]()
        didFetchBestLocation = done
        
        cancellableBlock = {
            if self.skipBlock == false {
                if self.locations.count > 0 {
                    let sortedLocations = sorted(self.locations, { (a, b) -> Bool in
                        return a.horizontalAccuracy < b.horizontalAccuracy
                    })
                    done(location: sortedLocations[0])
                }
            }
        }
        if let cancellableBlock = cancellableBlock {
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(timeout * Double(NSEC_PER_SEC)))
            dispatch_after(time, dispatch_get_main_queue(), cancellableBlock)
        }
    }
    
    public class func shared() -> LocationController {
        struct Static {
            static var instance: LocationController?
            static var once: dispatch_once_t = 0
        }
        dispatch_once(&Static.once) {
            Static.instance = LocationController()
            Static.instance?.locationManager.delegate = Static.instance!
        }
        return Static.instance!
    }
    
    public func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location: AnyObject = locations.last {
            if let location = location as? CLLocation {
                didUpdateLocation?(location: location)
                self.locations.append(location)
            }
        }
    }
    
    public func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        NSNotificationCenter.defaultCenter().postNotificationName("gps",
            object: nil)
        if didUpdateAuthorizationStatusBlock != nil {
            didUpdateAuthorizationStatusBlock!(status: status)
        }
        // Why whould we ask for access here? We should use this selector to update the UI
        //        if status == .NotDetermined {
        //            locationManager.requestAlwaysAuthorization()
        //        }
    }
    
    public func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }
}
