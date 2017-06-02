//
//  StartTrip.swift
//  gMaps
//
//  Created by Jose Mejia on 5/31/17.
//  Copyright © 2017 ITink. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class StartTrip: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        self.addTarget(self, action: #selector(StartTrip.goGmap), for: UIControlEvents.touchUpInside)
    }
    
    
    func goGmap(originCoordinates:CLLocationCoordinate2D, DestinationCoordinates:CLLocationCoordinate2D){
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.openURL(NSURL(string:
                "comgooglemaps://?saddr=\(Float(originCoordinates.latitude)),\(Float(originCoordinates.longitude))&daddr=\(Float(DestinationCoordinates.latitude)),\(Float(DestinationCoordinates.longitude))&directionsmode=driving")! as URL)
            
        } else {
            NSLog("Can't use comgooglemaps://");
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
