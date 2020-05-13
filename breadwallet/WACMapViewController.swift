//
//  WACMapViewController.swift
//  test3
//
//  Created by Gardner von Holt on 4/22/20.
//  Copyright © 2020 Gardner von Holt. All rights reserved.
//

import UIKit
import MapKit
import WacSDK

private let kAtmAnnotationViewReusableIdentifier = "kAtmAnnotationViewReusableIdentifier"

class WACMapViewController: UIViewController {

    var client: WAC?

    private static let meters: Int = 50000

    private let mapATMs = MKMapView.wrapping(meters: WACMapViewController.meters)
    private let searchQuery = UISearchBar()

    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        return _locationManager
    }()

    var pointAnnotation: MKPointAnnotation!
    var pinAnnotationView: MKPinAnnotationView!
    var atmAnnotations: Array<AtmAnnotation> = []
    
    var bottomSheetVC: WACSendVerificationCodeViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        initWAC()
        addSubviews()
        setupSearchQuery()
        addConstraints()
        setInitialData()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
        addBottomSheetView()
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapATMs.showsUserLocation = true
        }
    }

    func initWAC() {
        client = WAC.init()
        let listener = self
        client?.createSession(listener)
    }

    func addSubviews() {
        self.title = "ATM Cash Locations"
        view.backgroundColor = Theme.primaryBackground
        view.addSubview(searchQuery)
        view.addSubview(mapATMs)
    }

    func setupSearchQuery() {
        searchQuery.delegate = self
        searchQuery.backgroundColor = Theme.tertiaryBackground
        searchQuery.layer.cornerRadius = 2.0
    }

    func addConstraints() {

        searchQuery.constrain([
            searchQuery.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            searchQuery.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[1]),
            searchQuery.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[1]),
            searchQuery.constraint(.height, constant: 32)
        ])

        mapATMs.constrain([
            mapATMs.topAnchor.constraint(equalTo: searchQuery.bottomAnchor, constant: C.padding[1]),
            mapATMs.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[1]),
            mapATMs.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[1]),
            mapATMs.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0)
        ])

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
    
    func getAtmList() {
        client?.getAtmList(completion: { (response: WacSDK.AtmListResponse) in
            if let items = response.data?.items {
                for atmMachine in items {
                    let annotation = AtmAnnotation.init(atm: atmMachine)
                    self.atmAnnotations.append(annotation)
                }
            }
            self.mapATMs.addAnnotations(self.atmAnnotations)
        })
    }
    
    func addBottomSheetView() {
        bottomSheetVC = WACSendVerificationCodeViewController.init(nibName: "WACSendVerificationView", bundle: nil)
        self.addChild(bottomSheetVC!)
        self.view.addSubview(bottomSheetVC!.view)
        bottomSheetVC!.didMove(toParent: self)

        let height = bottomSheetVC!.view.frame.height
        let width  = view.frame.width
        bottomSheetVC!.view.frame = CGRect(x: 0, y: self.view.frame.size.height, width: width, height: height)
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

extension WACMapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        doSearch(search: searchBar.text!)
    }
}

extension WACMapViewController: SessionCallback {

    func onSessionCreated(_ sessionKey: String) {
        print(sessionKey)
        getAtmList()
    }

    func onError(_ errorMessage: String?) {
        showAlert(title: "Error", message: errorMessage!)
    }

}

extension WACMapViewController: AtmInfoViewDelegate {
    func detailsRequestedForAtm(atm: AtmMachine) {
        self.bottomSheetVC?.setAtmInfo(atm)
        self.bottomSheetVC?.showView()
        self.searchQuery.resignFirstResponder()
    }
}
