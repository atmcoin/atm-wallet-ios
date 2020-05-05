//
//  WACMapViewController.swift
//  test3
//
//  Created by Gardner von Holt on 4/22/20.
//  Copyright © 2020 Gardner von Holt. All rights reserved.
//

import UIKit
import MapKit

class WACMapViewController: UIViewController {

    @IBOutlet weak var mapATMs: MKMapView!
    @IBOutlet weak var searchQuery: UITextField!
    
    var locationManager = CLLocationManager()
    var matchingItems: [MKMapItem] = []

    var pointAnnotation: MKPointAnnotation!
    var pinAnnotationView: MKPinAnnotationView!


    override func viewDidLoad() {
        super.viewDidLoad()

        mapATMs.constrain([
            mapATMs.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[1]),
            mapATMs.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[1]) ])

        //Zoom to user location
        let noLocation = CLLocationCoordinate2D()
        let viewRegion = MKCoordinateRegion(center: noLocation, latitudinalMeters: 50000, longitudinalMeters: 50000)
        mapATMs.setRegion(viewRegion, animated: false)
//        mapATMs.showsUserLocation = true
        mapATMs.isScrollEnabled = true
        mapATMs.isZoomEnabled = true

        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .dark
        } else {
            // Fallback on earlier versions
        }

        // Do any additional setup after loading the view.
//        mapATMs.isUserLocationVisible = true
        mapATMs.delegate = self
        mapATMs.showsScale = true
        mapATMs.showsCompass = true

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self

        // Check for Location Services
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        }

        //Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 50000, longitudinalMeters: 50000)
            mapATMs.setRegion(viewRegion, animated: false)
        }

        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func Close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func search(_ sender: Any) {
        doSearch()
    }

    func doSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery.text
        request.region = mapATMs.region
        let search = MKLocalSearch(request: request)

        search.start { response, _ in
            guard let response = response else {
                return
            }

            let region = response.boundingRegion
            let point = region.center
            let coordinate = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)

            self.mapATMs.centerCoordinate = coordinate
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension WACMapViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        let region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude),
                                        latitudinalMeters: 50000, longitudinalMeters: 50000)
        mapATMs.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
}

extension WACMapViewController: MKMapViewDelegate {

}

extension WACMapViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        doSearch()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        doSearch()
        return true
    }
}
