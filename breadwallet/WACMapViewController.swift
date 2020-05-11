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

class WACMapViewController: UIViewController {

    var client: WAC?

    private static let meters: Int = 50000

    private let headingLabel = UILabel()
    private let mapATMs = MKMapView.wrapping(meters: WACMapViewController.meters)
    private let searchQuery = UITextField()
    private let searchButton = UIButton()
    private let closeButton = BRDButton(title: S.Button.close, type: .primary)

    private let headingTopMargin: CGFloat = 28
    private let headingLeftRightMargin: CGFloat = 25

    private let searchButtonHeight: CGFloat = 30
    private let searchButtonWidth: CGFloat = 50

    var locationManager = CLLocationManager()
    var matchingItems: [MKMapItem] = []

    var pointAnnotation: MKPointAnnotation!
    var pinAnnotationView: MKPinAnnotationView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initWAC()
        addSubviews()
        setupSearchQuery()
        addConstraints()
        initLabels()
        setInitialData()
    }

    func initWAC() {
        client = WAC.init()
        let listener = self
        client?.login(listener)
    }

    func addSubviews() {
        view.addSubview(headingLabel)
        view.addSubview(searchQuery)
        view.addSubview(searchButton)
        view.addSubview(mapATMs)
        view.addSubview(closeButton)
    }

    func setupSearchQuery() {
        searchQuery.delegate = self
        searchQuery.backgroundColor = Theme.tertiaryBackground
        searchQuery.layer.cornerRadius = 2.0
        searchQuery.textColor = Theme.primaryText
//        searchQuery.attributedPlaceholder = NSAttributedString(string: "search string",
//                                                              attributes: [ NSAttributedString.Key.foregroundColor: UIColor.emailPlaceholderText ])
    }

    func addConstraints() {

        headingLabel.constrain([
            headingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: headingTopMargin),
            headingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[1]),
            headingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[1])
        ])

        searchQuery.constrain([
            searchQuery.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: C.padding[1]),
            searchQuery.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[1]),
            searchQuery.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[1]),
            searchQuery.constraint(.height, constant: searchButtonHeight)
        ])

        searchButton.constrain([
            searchButton.topAnchor.constraint(equalTo: searchQuery.bottomAnchor, constant: C.padding[2]),
            searchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[1]),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[1]),
            searchButton.constraint(.height, constant: searchButtonHeight)
        ])

        mapATMs.constrain([
            mapATMs.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: C.padding[1]),
            mapATMs.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[1]),
            mapATMs.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[1]),
            mapATMs.heightAnchor.constraint(equalTo: mapATMs.widthAnchor, multiplier: 1.0)
        ])

        closeButton.constrain([
            closeButton.topAnchor.constraint(greaterThanOrEqualTo: mapATMs.bottomAnchor, constant: C.padding[1]),
            closeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: headingLeftRightMargin),
            closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -headingLeftRightMargin),
            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -headingTopMargin)
        ])

    }

    func initLabels() {
        headingLabel.textColor = Theme.primaryText
        headingLabel.font = Theme.h2Title
        headingLabel.text = S.ATMMapView.title
        headingLabel.textAlignment = .center
        headingLabel.numberOfLines = 1
        headingLabel.adjustsFontSizeToFitWidth = true
    }

    func setInitialData() {
        //searchButton.setTitle(S.Button.search, for: .normal)

        mapATMs.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self

        // Check for Location Services
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        }

        //Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation,
                                                latitudinalMeters: CLLocationDistance(WACMapViewController.meters),
                                                longitudinalMeters: CLLocationDistance(WACMapViewController.meters))
            mapATMs.setRegion(viewRegion, animated: false)
        }

        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }

        searchButton.tap = strongify(self) { myself in
            myself.searchQuery.resignFirstResponder()
            myself.doSearch(search: myself.searchQuery.text!)
        }

        closeButton.tap = strongify(self) { myself in
            myself.dismiss(animated: true, completion: nil)
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
                                                            latitudinalMeters: CLLocationDistance(WACMapViewController.meters),
                                                            longitudinalMeters: CLLocationDistance(WACMapViewController.meters))
        mapATMs.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
}

extension WACMapViewController: MKMapViewDelegate {

}

extension WACMapViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        doSearch(search: textField.text!)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        doSearch(search: textField.text!)
        return true
    }
}

extension WACMapViewController: LoginProtocol {

    func onLogin(_ sessionKey: String) {
        print(sessionKey)
        clientSessionKey = sessionKey
    }

    func onError(_ errorMessage: String?) {
        showAlert("Error", message: errorMessage!)
    }

}
