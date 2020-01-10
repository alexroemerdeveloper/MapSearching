//
//  MapSearchingViewModel.swift
//  MapSearching
//
//  Created by Alexander Römer on 10.01.20.
//  Copyright © 2020 Alexander Römer. All rights reserved.
//

import SwiftUI
import CoreLocation
import MapKit
import Combine

class MapSearchingViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var annotations      = [MKPointAnnotation]()
    @Published var isSearching      = false
    @Published var searchQuery      = ""
    @Published var mapItems         = [MKMapItem]()
    @Published var selectedMapItem  : MKMapItem?
    @Published var keyboardHeight   : CGFloat = 0
    @Published var currentLocation  = CLLocationCoordinate2D(latitude: 37.7666, longitude: -122.427290)
    
    private var cancellable         : AnyCancellable?
    private let locationManager     = CLLocationManager()
    private var region              : MKCoordinateRegion?
    
    override init() {
        super.init()
        cancellable = $searchQuery.debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] (searchTerm) in
                self?.performSearch(query: searchTerm)
        }
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        listenForKeyboardNotifications()
        
        NotificationCenter.default.addObserver(forName: MapViewContainer.Coordinator.regionChangedNotification, object: nil, queue: .main) { [weak self] (notification) in
            self?.region = notification.object as? MKCoordinateRegion
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let firstLocation = locations.first else { return }
        self.currentLocation = firstLocation.coordinate
    }
    
    fileprivate func listenForKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] (notification) in
            guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
            let keyboardFrame = value.cgRectValue
            let window = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
            
            withAnimation(.easeOut(duration: 0.25)) {
                self?.keyboardHeight = keyboardFrame.height - window!.safeAreaInsets.bottom
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] (notification) in
            withAnimation(.easeOut(duration: 0.25)) {
                self?.keyboardHeight = 0
            }
        }
    }
    
    fileprivate func performSearch(query: String) {
        isSearching = true
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        if let region = self.region {
            request.region = region
        }
        
        let localSearch = MKLocalSearch(request: request)
        
        localSearch.start { (resp, err) in
            
            self.mapItems          = resp?.mapItems ?? []
            var airportAnnotations = [MKPointAnnotation]()
            
            resp?.mapItems.forEach({ (mapItem) in
                print(mapItem.name ?? "")
                let annotation = MKPointAnnotation()
                annotation.title = mapItem.name
                annotation.coordinate = mapItem.placemark.coordinate
                airportAnnotations.append(annotation)
            })
            self.isSearching = false
            self.annotations = airportAnnotations
        }
    }
}
