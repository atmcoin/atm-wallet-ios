//
//  WACMapViewController.swift
//
//  Created by Giancarlo Pacheco on 5/14/20.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import MapKit
import WacSDK

private let kAtmAnnotationViewReusableIdentifier = "kAtmAnnotationViewReusableIdentifier"
private let kLocationDistance: Double = 50000
private let kHoustonLocation = CLLocation(latitude: 29.749907, longitude: -95.358421)

// TODO: Localize strings
class WACMapViewController: UIViewController {

    private var _atmList: [AtmMachine]?
    public var atmList: [AtmMachine]? {
        get {
            return _atmList
        }
        set {
            _atmList = newValue
            if let items = _atmList {
                for atmMachine in items {
                    let annotation = AtmAnnotation.init(atm: atmMachine)
                    self.atmAnnotations.append(annotation)
                }
            }
            self.mapATMs.addAnnotations(self.atmAnnotations)
        }
    }

    private let mapATMs = MKMapView()

    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        return _locationManager
    }()

    var atmAnnotations: Array<AtmAnnotation> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupMapView()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
        addConstraints()
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapATMs.showsUserLocation = true
        }
    }
    
    func addSubviews() {
        view.backgroundColor = .clear
        view.addSubview(mapATMs)
    }

    func addConstraints() {
        let parent = self.parent as! WACAtmLocationsViewController
        mapATMs.constrain([
            mapATMs.topAnchor.constraint(equalTo: parent.containerView.topAnchor, constant: 0),
            mapATMs.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapATMs.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapATMs.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0)
        ])

    }
    
    func setupMapView() {
        mapATMs.isScrollEnabled = true
        mapATMs.isZoomEnabled = true

        if #available(iOS 13.0, *) {
            mapATMs.overrideUserInterfaceStyle = .dark
        }
        mapATMs.showsScale = true
        mapATMs.showsCompass = true
        
        mapATMs.register(AtmAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapATMs.delegate = self
    }
    
    @objc func containerViewTapped(_ sender: Any) {
        view.endEditing(true)
        let parent = self.parent as! WACAtmLocationsViewController
        parent.searchBar.resignFirstResponder()
    }

    func doSearch(search: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = search
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

}

extension WACMapViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapATMs.centerToLocation(kHoustonLocation, regionRadius: 50000)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}

extension WACMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            if annotation is MKUserLocation { return nil }
            
            var annotationView = mapATMs.dequeueReusableAnnotationView(withIdentifier: kAtmAnnotationViewReusableIdentifier)
            
            if annotationView == nil {
                annotationView = AtmAnnotationView(annotation: annotation, reuseIdentifier: kAtmAnnotationViewReusableIdentifier)
                (annotationView as! AtmAnnotationView).atmMarkerAnnotationViewDelegate = self
            } else {
                annotationView!.annotation = annotation
            }
            
            return annotationView
        }
}

extension WACMapViewController: AtmInfoViewDelegate {
    func detailsRequestedForAtm(atm: AtmMachine) {
        let parent = self.parent as! WACAtmLocationsViewController
        parent.sendVerificationVC?.setAtmInfo(atm)
        parent.sendVerificationVC?.showView()
        parent.searchBar.resignFirstResponder()

        parent.verifyCashCodeVC!.atm = atm
    }
}
