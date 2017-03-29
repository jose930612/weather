//
//  ViewController.swift
//  gMaps
//
//  Created by Jose Mejia on 2/23/17.
//  Copyright © 2017 ITink. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

//var weather:[String]!=[]


class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var temperature: tempView!
    var popOverVC = PopupViewController()
    
    let locationManager = CLLocationManager()
    let myLocationMarker = GMSMarker()
    
    @IBOutlet weak var PressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    var pressureText:String!
    var humidityText:String!
    var weatherText:String!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        temperature.detailPopup.addTarget(self, action: #selector(ViewController.popUpView), for: UIControlEvents.touchUpInside)
        
        temperature.refreshButton.addTarget(self, action: #selector(ViewController.request), for: UIControlEvents.touchUpInside)
        
        self.temperature.detailPopup.isHidden = true
        self.temperature.refreshButton.isHidden = true
    }
    
    
    func popUpView() {
        
        popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier :"sbPopupID") as! PopupViewController
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        
        self.popOverVC.humidityInfo.text = self.humidityText
        self.popOverVC.pressureInfo.text = self.pressureText
        self.popOverVC.weatherInfo.text = self.weatherText
        
    }
    
    
    @IBAction func searchButton(_ sender: Any) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15.0)
        self.mapView.camera = camera
        
        let position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        let marker = GMSMarker(position: position)
        marker.title = "\(place.name)"
        marker.map = mapView
        
        self.dismiss(animated: true, completion: nil) // dismiss after select place
        
    }
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
        print("ERROR AUTO COMPLETE \(error)")
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil) // when cancel search
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            
            mapView.isMyLocationEnabled = true
            mapView.isTrafficEnabled = true
            mapView.mapType = GoogleMaps.kGMSTypeNormal
            mapView.settings.myLocationButton = true
            mapView.accessibilityElementsHidden = false

        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            
            mapView.camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 17)
            request(coordinates: location.coordinate)
            
            locationManager.stopUpdatingLocation()
        }
        
    }
    
    func request (coordinates:CLLocationCoordinate2D) {
        
        let urlString = "http://api.openweathermap.org/data/2.5/weather?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&APPID=722e31fed4758ec43905b234ed67369d&lang=sp"
        
        var request = URLRequest(url: URL(string: urlString)!)
        
        request.httpMethod = "GET"
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String, AnyObject>
            
            let results:Dictionary<String, AnyObject>! = json
            
            
            DispatchQueue.main.async(execute: {
                
                if let weather = results["weather"] as? [[String:Any]], !weather.isEmpty {
                    print(weather[0]["description"]!) // the value is an optional.
                    self.weatherText = "\(weather[0]["description"]!)"
                }
                
                //self.tableView.reloadData()
                let kelvin = results["main"]?["temp"] as! Double
                let celsius = round(kelvin - 273.15)
                
                let hPa = results["main"]?["pressure"] as! Double
                
                let pressure = round(hPa / 1013.25)
                let doubleStr = String(format: "%.2f", pressure) // "3.14"
                self.temperature.temp = "\(NSNumber(value: celsius))ºC"
                
                self.pressureText = "Pressure: \(doubleStr) Atm"
                self.humidityText = "Humidity: \(NSNumber(value: (results["main"]?["humidity"]) as! Double))%"
            })
            
            }.resume()
        
    }

}
