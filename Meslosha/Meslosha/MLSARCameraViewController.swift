//
//  MLSARCameraViewController.swift
//  Meslosha
//
//  Created by VAN DAO on 5/3/17.
//  Copyright © 2017 VAN DAO. All rights reserved.
//

import Foundation
import UIKit

class MLSARCameraViewController : ARViewController {
    
    var places = [Place]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        //2
        self.maxVisibleAnnotations = 30
        self.headingSmoothingFactor = 0.05
        //3
        self.setAnnotations(places)
    }
    
    func showInfoView(forPlace place: Place) {
        //1
        let alert = UIAlertController(title: place.placeName , message: place.infoText, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        //2
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backTouchUpInside(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
    }
}

extension MLSARCameraViewController: ARDataSource {
    
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let markerView = MarkerView()
        markerView.annotation = viewForAnnotation
        markerView.delegate = self
        markerView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        
        return markerView
    }
}

extension MLSARCameraViewController: MarkerViewDelegate {
    func didTouch(markerView: MarkerView) {
        
        if let marker = markerView.annotation as? Place {
            //2
            let placesLoader = PlacesLoader()
            placesLoader.loadDetailInformation(forPlace: marker) { resultDict, error in
                
                //3
                if let infoDict = resultDict?.object(forKey: "result") as? NSDictionary {
                    marker.phoneNumber = infoDict.object(forKey: "formatted_phone_number") as? String
                    marker.website = infoDict.object(forKey: "website") as? String
                    
                    //4
                    self.showInfoView(forPlace: marker)
                }
            }
        }
    }
}

