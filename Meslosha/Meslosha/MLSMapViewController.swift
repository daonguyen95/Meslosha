//
//  MLSMapViewController.swift
//  Meslosha
//
//  Created by VAN DAO on 5/3/17.
//  Copyright © 2017 VAN DAO. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces

class MLSMapViewController : UIViewController {
    
    @IBOutlet var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var placesAnnotation = NSMutableArray()
    var didFindMyLocation = false
    var newMarker: GMSMarker?
    var projection: GMSProjection? = nil
    
    @IBOutlet var settingButton: UIButton!
    @IBOutlet var markerButton: UIButton!
    @IBOutlet var addMarkerButton: UIButton!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var markerCenterImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.view.bringSubview(toFront: settingButton)
//        self.view.bringSubview(toFront: markerButton)
//        self.view.bringSubview(toFront: addMarkerButton)
//        self.view.bringSubview(toFront: cameraButton)
//        self.view.sendSubview(toBack: mapView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true;
        
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = false
        
        projection = mapView.projection
        
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if !didFindMyLocation {
            
            let myLocation: CLLocation = change![NSKeyValueChangeKey.newKey] as! CLLocation
            
            // do whatever you want here with the location
            mapView.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 15.0)
            
            didFindMyLocation = true
        }
    }
    
    @IBAction func currentLocationTouchUpInside(_ sender: Any) {
        let location = mapView.myLocation
        
        if let location = location {
            let camera = GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude), zoom: 15)
            mapView.animate(to: camera)
        }
    }
    
    @IBAction func settingTouchUpInside(_ sender: Any) {
        print("Setting Touch Up Inside")
    }
    
    @IBAction func addMarkerTouchDown(_ sender: Any) {
        mapView.isUserInteractionEnabled = false
    }
    
    var isAddNewMarker: Bool = true
    @IBAction func addMarkerTouchUpInside(_ sender: Any) {
        print("Add Marker Touch Up Inside")
        
        if isAddNewMarker {
            self.markerCenterImage.isHidden = false
            self.addMarkerButton.setImage(UIImage.init(named: "checked-icon"), for: .normal)
            
            isAddNewMarker = false
        } else {
            let userMarker = GMSMarker()
            
            let projection = mapView.projection
            let newCoordinate = projection.coordinate(for: CGPoint.init(x: self.mapView.center.x, y: self.mapView.center.y - 18))
            
            userMarker.icon = UIImage.init(named: "locationmarker-icon")!.resizeImage(newWidth: 20)
            userMarker.position = newCoordinate
            userMarker.appearAnimation = GMSMarkerAnimation.pop
            userMarker.title = "User marker"
            userMarker.appearAnimation = .pop
            userMarker.map = mapView

            self.markerCenterImage.isHidden = true
            self.addMarkerButton.setImage(UIImage.init(named: "Add-icon"), for: .normal)
            isAddNewMarker = true
        }
        mapView.isUserInteractionEnabled = true
    }
    
    var previousLocation: CGPoint = CGPoint.zero

    @IBAction func addMarkerTouchDragInside(_ sender: Any, forEvent event: UIEvent) {
        let touch = event.touches(for: sender as! UIButton)?.first
        let newLocation = touch!.location(in: self.mapView)
        
        print(newLocation)
        print(previousLocation)
        print(previousLocation.distance(toPoint: newLocation))
        //        print(previousLocation.distance(toPoint: newLocation))
//        if (!previousLocation.equalTo(CGPoint.zero) && previousLocation.distance(toPoint: newLocation) < 100) {
//            return
//        }
        
        let projection = mapView.projection
        let newCoordinate = projection.coordinate(for: newLocation)
        
        if newMarker == nil {
            newMarker = GMSMarker()
            
            newMarker?.icon = UIImage.init(named: "locationmarker-icon")!.resizeImage(newWidth: 20)
            newMarker?.position = newCoordinate
            newMarker?.appearAnimation = GMSMarkerAnimation.pop
            newMarker?.title = "User marker"
            newMarker?.appearAnimation = .none
            newMarker?.map = mapView
        } else {
            newMarker?.position = newCoordinate
            print("hahah")
        }
        
        print("until you")
        
        previousLocation = newLocation
    }

    @IBAction func addMarkerTouchDragOutside(_ sender: Any, forEvent event: UIEvent) {
        
        let touch = event.touches(for: sender as! UIButton)?.first
        let newLocation = touch!.location(in: self.mapView)
        
//        print(previousLocation.distance(toPoint: newLocation))
        if (!previousLocation.equalTo(CGPoint.zero) && previousLocation.distance(toPoint: newLocation) < 100) {
            return
        }
        
        let projection = mapView.projection
        let newCoordinate = projection.coordinate(for: newLocation)
        
        if newMarker == nil {
            newMarker = GMSMarker()
            
            newMarker?.icon = UIImage.init(named: "locationmarker-icon")!.resizeImage(newWidth: 20)
            newMarker?.position = newCoordinate
            newMarker?.appearAnimation = GMSMarkerAnimation.pop
            newMarker?.title = "User marker"
            newMarker?.appearAnimation = .none
            newMarker?.map = mapView
        } else {
//            CATransaction.begin()
//            CATransaction.setAnimationDuration(2.0)
            newMarker?.position = newCoordinate
//            CATransaction.commit()
        }
        
        previousLocation = newLocation
    }
    
    @IBAction func addMarkerTouchUpOutSide(_ sender: Any) {
        print("Add Marker Touch Up Outside")
        
        newMarker = nil
        mapView.isUserInteractionEnabled = true
    }
}

extension MLSMapViewController: GMSAutocompleteFetcherDelegate {
    func didFailAutocompleteWithError(_ error: Error) {
        
    }
    
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        
    }
}

extension MLSMapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let inforWindow = UIView()
        
        inforWindow.frame = CGRect(x: 0, y: 0, width: 200, height: 70)
        inforWindow.backgroundColor = UIColor.gray
        
        let titleLabel = UILabel()
        let snippetLabel = UILabel()
        titleLabel.frame = CGRect(x: 14.0, y: 11.0, width: 175.0, height: 16.0)
        snippetLabel.frame = CGRect(x: 14.0, y: 42.0, width: 175.0, height: 16.0)
        snippetLabel.text = marker.snippet
        snippetLabel.textColor = UIColor.white
        titleLabel.text = marker.title
        titleLabel.textColor = UIColor.white
        inforWindow.addSubview(titleLabel)
        inforWindow.addSubview(snippetLabel)
        
        return inforWindow
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
    }
}

extension MLSMapViewController: CLLocationManagerDelegate {
    
}
