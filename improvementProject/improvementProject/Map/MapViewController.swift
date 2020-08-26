//
//  MapViewController.swift
//  improvementProject
//
//  Created by chen yue on 2020/8/26.
//  Copyright © 2020 chen yue. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var locationMap: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(locationMap, completionHandler: { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            
            if let placemarks = placemarks {
                
                let placemark = placemarks[0]
                
                let annotation = MKPointAnnotation()
                annotation.title = self.locationMap
                
                if let location = placemark.location {
                    annotation.coordinate = location.coordinate
                    
                    self.mapView.showAnnotations([annotation], animated: true)
                    self.mapView.selectAnnotation(annotation, animated: true)
                }
            }
            
        })
        
        
        // Configure map view
        mapView.delegate = self
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = true
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyMarker"
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        var annotationView: MKMarkerAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        annotationView?.glyphText = "😋"
        annotationView?.markerTintColor = UIColor.orange
        
        return annotationView
    }
}
