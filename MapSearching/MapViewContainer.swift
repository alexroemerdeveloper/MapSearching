//
//  MapViewContainer.swift
//  MapSearching
//
//  Created by Alexander Römer on 10.01.20.
//  Copyright © 2020 Alexander Römer. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit

struct MapViewContainer: UIViewRepresentable {
    
    internal var annotations        = [MKPointAnnotation]()
    internal var selectedMapItem    : MKMapItem?
    internal var currentLocation    = CLLocationCoordinate2D(latitude: 37.7666, longitude: -122.427290)
    private let mapView             = MKMapView()
    typealias UIViewType            = MKMapView
    
    
    func makeCoordinator() -> MapViewContainer.Coordinator {
        return Coordinator(mapView: mapView)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        init(mapView: MKMapView) {
            super.init()
            mapView.delegate = self
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            if !(annotation is MKPointAnnotation) { return nil }
            
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
            pinAnnotationView.canShowCallout = true
            return pinAnnotationView
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            NotificationCenter.default.post(name: MapViewContainer.Coordinator.regionChangedNotification, object: mapView.region)
        }
        
        static let regionChangedNotification = NSNotification.Name("regionChangedNotification")
    }
    
    // treat this as your setup area
    func makeUIView(context: UIViewRepresentableContext<MapViewContainer>) -> MKMapView {
        setupRegionForMap()
        mapView.showsUserLocation = true
        return mapView
    }
    
    fileprivate func setupRegionForMap() {
        let centerCoordinate = CLLocationCoordinate2D(latitude: 37.7666, longitude: -122.427290)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapViewContainer>) {
        
        if annotations.count == 0 {
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: currentLocation, span: span)
            uiView.setRegion(region, animated: true)
            
            uiView.removeAnnotations(uiView.annotations)
            return
        }
        
        if shouldRefreshAnnotations(mapView: uiView) {
            uiView.removeAnnotations(uiView.annotations)
            uiView.addAnnotations(annotations)
            uiView.showAnnotations(uiView.annotations.filter{$0 is MKPointAnnotation}, animated: false)
        }
        
        uiView.annotations.forEach { (annotation) in
            if annotation.title == selectedMapItem?.name {
                uiView.selectAnnotation(annotation, animated: true)
            }
        }
    }
    
    
    fileprivate func shouldRefreshAnnotations(mapView: MKMapView) -> Bool {
        let grouped = Dictionary(grouping: mapView.annotations, by: { $0.title ?? ""})
        for (_, annotation) in annotations.enumerated() {
            if grouped[annotation.title ?? ""] == nil {
                return true
            }
        }
        return false
    }
    
    
}
