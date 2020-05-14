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

// TODO: Localize strings
class WACMapViewController: UIViewController {

    public var client: WAC?
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

    private static let meters: Int = 50000

    private let mapATMs = MKMapView.wrapping(meters: WACMapViewController.meters)
//    private var parentVC: WACAtmLocationsViewController = {
//        return self.parent
//    }()

    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        return _locationManager
    }()

    var pointAnnotation: MKPointAnnotation!
    var pinAnnotationView: MKPinAnnotationView!
    var atmAnnotations: Array<AtmAnnotation> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setInitialData()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(containerViewTapped))
//        mapATMs.addGestureRecognizer(tapRecognizer)
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
    
    @objc func containerViewTapped(_ sender: Any) {
        view.endEditing(true)
        let parent = self.parent as! WACAtmLocationsViewController
        parent.searchBar.resignFirstResponder()
    }

    func setInitialData() {
        mapATMs.register(AtmAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapATMs.delegate = self

        //Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation,
                                                latitudinalMeters: CLLocationDistance(WACMapViewController.meters),
                                                longitudinalMeters: CLLocationDistance(WACMapViewController.meters))
            mapATMs.setRegion(viewRegion, animated: false)
        }
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
        let location = locations.last!
        let region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude),
                                                            latitudinalMeters: CLLocationDistance(WACMapViewController.meters),
                                                            longitudinalMeters: CLLocationDistance(WACMapViewController.meters))
        mapATMs.setRegion(region, animated: true)
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
