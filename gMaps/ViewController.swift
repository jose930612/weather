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

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var destinationWeatherView: DestinationWeatherView!
    @IBOutlet weak var temperature: tempView!
    var popOverVC = PopupViewController()
    
    let locationManager = CLLocationManager()
    let myLocationMarker = GMSMarker()
    
    var pressureText:String!
    var humidityText:String!
    var weatherText:String!
    var weatherCode:Int!
    
    var imgIconUrl:URL!
    var isStationAvailable = true
    
    let RESIZE_FACTOR = CGFloat(80.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        temperature.detailPopup.addTarget(self, action: #selector(ViewController.popUpView), for: UIControlEvents.touchUpInside)
        
        temperature.refreshButton.addTarget(self, action: #selector(ViewController.updateWeather), for: UIControlEvents.touchUpInside)
        destinationWeatherView.closeButton.addTarget(self, action: #selector(ViewController.closeWeatherDetails), for: UIControlEvents.touchUpInside)
        
        self.temperature.detailPopup.isHidden = true
        self.temperature.refreshButton.isHidden = true
        self.destinationWeatherView.isHidden = true
        
        
    }
    
    func updateWeather() {
        if isStationAvailable {
            print("stationDataRequest")
            stationDataRequest(coordinates: (locationManager.location?.coordinate)!)
        } else {
            print("request")
            request(coordinates: (locationManager.location?.coordinate)!)
        }
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
        
        var imgName:String!
        
        if weatherCode == 800 {
            imgName="sunny"
        }
        
        if weatherCode > 800 && weatherCode < 900 {
            imgName="cloudy"
        }
        
        if (weatherCode >= 900 && weatherCode < 1000) || (weatherCode >= 500 && weatherCode < 600) || (weatherCode >= 200 && weatherCode < 400) {
            imgName="rainy"
        }
        
        self.popOverVC.weatherImgIcon.image = UIImage(named:imgName)
        
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
        
        howsTheWeatherThere(placeName: place.name, coordinate: place.coordinate)
        
        self.mapView.frame = CGRect(x: 0, y: 0, width: self.mapView.frame.width, height: (self.mapView.frame.height-RESIZE_FACTOR))
        
        self.dismiss(animated: true, completion: nil) // dismiss after select place
        
    }
    
    func howsTheWeatherThere(placeName:String, coordinate:CLLocationCoordinate2D ) {
        self.destinationWeatherView.isHidden = false
        self.destinationWeatherView.locationLabel.text = placeName
        destinationRequest (coordinates:coordinate)
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
            print("SCREEEEEEEEEAM")
            if isStationAvailable {
                //print("Station is available")
                stationDataRequest(coordinates: location.coordinate)
            } else {
                request(coordinates: location.coordinate)
            }
            
            /*self.myLocationMarker.position = location.coordinate
            self.myLocationMarker.map = mapView*/
            
            locationManager.stopUpdatingLocation()
        } else {
            
        }
        
    }
    
    func stationDataRequest(coordinates:CLLocationCoordinate2D) {
        
        var weatherData:[String:Any]!
        let urlString = "http://weatherstation.local:8080/lastmeasure"
        
        var request = URLRequest(url: URL(string: urlString)!)
        
        request.httpMethod = "GET"
        //var session = URLSession.shared
        
        let urlconfig = URLSessionConfiguration.default
        urlconfig.timeoutIntervalForRequest = 8
        urlconfig.timeoutIntervalForResource = 8
        let session = URLSession(configuration: urlconfig, delegate: self as? URLSessionDelegate, delegateQueue: nil)
        
        session.dataTask(with: request) {data, response, error in
            guard error == nil else {
                //print(error!)
                print("ERROR!!!!")
                self.isStationAvailable = false
                self.request(coordinates: coordinates)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as! [Any]
                guard let datos = json.first as? [String:Any] else {return}
                print(datos["temperature"])
                weatherData = datos
            } catch {
                print(error)
            }
            
            DispatchQueue.main.async(execute: {
                
                self.weatherCode = 800
                self.weatherText = "--"
                
                let celsius = weatherData["temperature"]!
                
                let pressure = weatherData["pressure"]!
                let doubleStr = "\(pressure)" // "3.14"
                self.temperature.temp = "\(celsius)ºC"
                
                self.pressureText = "\(doubleStr) hPa"
                self.humidityText = "\(weatherData["humidity"]!)%"
            })
            
            }.resume()
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
                    //print(weather[0]["description"]!) // the value is an optional.
                    
                    self.weatherCode = NumberFormatter().number(from: "\(weather[0]["id"]!)") as Int!
                    //print(weather[0])
                    self.weatherText = "\(weather[0]["description"]!)"
                    
                    let weatherIcon = "\(weather[0]["icon"]!)"
                    
                    self.imgIconUrl  = URL(string: "http://openweathermap.org/img/w/\(weatherIcon).png")
                    
                    /*let session = URLSession(configuration: .default)
                    
                    // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
                    let downloadPicTask = session.dataTask(with: self.imgIconUrl) { (data, response, error) in
                        // The download has finished.
                        if let e = error {
                            print("Error downloading cat picture: \(e)")
                        } else {
                            // No errors found.
                            // It would be weird if we didn't have a response, so check for that too.
                            if let res = response as? HTTPURLResponse {
                                print("Downloaded cat picture with response code \(res.statusCode)")
                                if let imageData = data {
                                    // Finally convert that Data into an image and do what you wish with it.
                                    self.myLocationMarker.icon = UIImage(data: imageData)
                                    // Do something with your image.
                                } else {
                                    print("Couldn't get image: Image is nil")
                                }
                            } else {
                                print("Couldn't get response code for some reason")
                            }
                        }
                    }
                    
                    downloadPicTask.resume()*/
                    
                }
                
                //self.tableView.reloadData()
                let kelvin = results["main"]?["temp"] as! Double
                let celsius = round(kelvin - 273.15)
                
                let hPa = results["main"]?["pressure"] as! Double
                
                let pressure = round(hPa / 1013.25)
                let doubleStr = String(format: "%.2f", pressure) // "3.14"
                self.temperature.temp = "\(NSNumber(value: celsius))ºC"
                
                self.pressureText = "\(doubleStr) Atm"
                self.humidityText = "\(NSNumber(value: (results["main"]?["humidity"]) as! Double))%"
            })
            
            }.resume()
        
    }
    
    func closeWeatherDetails(){
        self.destinationWeatherView.isHidden = true
        self.mapView.frame = CGRect(x: 0, y: 0, width: self.mapView.frame.width, height: (self.mapView.frame.height+(RESIZE_FACTOR+20)))
        self.mapView.clear()
        mapView.camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: 17)
    }
    
    func destinationRequest (coordinates:CLLocationCoordinate2D) {
        
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
                
                /*if let weather = results["weather"] as? [[String:Any]], !weather.isEmpty {
                    //print(weather[0]["description"]!) // the value is an optional.
                    
                    self.weatherCode = NumberFormatter().number(from: "\(weather[0]["id"]!)") as Int!
                    //print(weather[0])
                    self.weatherText = "\(weather[0]["description"]!)"
                    
                    let weatherIcon = "\(weather[0]["icon"]!)"
                    
                    self.imgIconUrl  = URL(string: "http://openweathermap.org/img/w/\(weatherIcon).png")
                }*/
                
                //self.tableView.reloadData()
                let kelvin = results["main"]?["temp"] as! Double
                let celsius = round(kelvin - 273.15)
                
                let hPa = results["main"]?["pressure"] as! Double
                
                let pressure = round(hPa / 1013.25)
                let doubleStr = String(format: "%.2f", pressure) // "3.14"
                self.destinationWeatherView.temperatureLabel.text = "Temperature: \(NSNumber(value: celsius))ºC"
                self.destinationWeatherView.humidityLabel.text = "Humidity: \(NSNumber(value: (results["main"]?["humidity"]) as! Double))%"
                self.destinationWeatherView.pressureLabel.text = "Pressure: \(hPa) hPa"
            })
            
            }.resume()
        
    }
}
