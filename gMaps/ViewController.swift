//
//  ViewController.swift
//  gMaps
//
//  Created by Jose Mejia on 2/23/17.
//  Copyright © 2017 ITink. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import GooglePlaces

extension String {
    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate {
    
    let RESIZE_FACTOR = CGFloat(100.0)
    let screenSize = UIScreen.main.bounds
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var destinationWeatherView: DestinationWeatherView!
    @IBOutlet weak var temperature: tempView!
    var popOverVC = PopupViewController()
    
    let locationManager = CLLocationManager()
    var placesMarkers:Dictionary<String,[GMSMarker]> = Dictionary<String,[GMSMarker]>()
    
    var pressureText:String!
    var humidityText:String!
    var weatherText:String!
    var weatherCode:Int!
    
    var imgIconUrl:URL!
    var isStationAvailable = true
    var isNearbyCalled = false
    
    let weatherPlaces:Dictionary<String,[String]> = [
        "rainy":["art_gallery",
                 "cafe",
                 "movie_theater",
                 "restaurant",
                 "shopping_mall"],
        "cloudy":["art_gallery",
                  "cafe",
                  "movie_theater",
                  "restaurant",
                  "shopping_mall"],
        "sunny":["museum",
                 "park",
                 "cafe",
                 "park",
                 "restaurant",
                 "zoo"],
        "night":["night_club",
                 "restaurant",
                 "cafe",
                 "movie_theater"]
    ]
    
    let type = ["art_gallery","cafe", "movie_theater", "restaurant", "shopping_mall", "museum", "park", "restaurant", "zoo", "night_club"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        temperature.detailPopup.addTarget(self, action: #selector(ViewController.popUpView), for: UIControlEvents.touchUpInside)
        
        temperature.refreshButton.addTarget(self, action: #selector(ViewController.updateWeather), for: UIControlEvents.touchUpInside)
        destinationWeatherView.closeButton.addTarget(self, action: #selector(ViewController.closeWeatherDetails), for: UIControlEvents.touchUpInside)
        
        self.temperature.detailPopup.isHidden = true
        self.temperature.refreshButton.isHidden = true
        self.temperature.settingButton.isHidden = true
        self.temperature.routeButton.isHidden = true
        self.destinationWeatherView.isHidden = true
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Place_type")
        
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    result.setValue(false, forKey: "isSelected")
                }
            } else {
                print("No results")
            }
            
        } catch {
            print("Couldn't fetch results")
        }
        
        /*
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        for typeValue in type {
            let placeType = NSEntityDescription.insertNewObject(forEntityName: "Place_type", into: context)
            placeType.setValue("\(typeValue)", forKey: "type")
            placeType.setValue(false, forKey: "isSelected")
            
            do {
                try context.save()
                print("saved")
            } catch {
                print("There was an error")
            }
        }
        */
        
    }
    
    func updateWeather() {
        if isStationAvailable {
            print("stationDataRequest")
            stationDataRequest(coordinates: (locationManager.location?.coordinate)!)
        } else {
            print("request")
            isNearbyCalled = false
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
        
        //print(self.screenSize.height)
        
        self.mapView.frame = CGRect(x: 0, y: 0, width: self.mapView.frame.width, height: (self.screenSize.height-RESIZE_FACTOR))
        
        self.dismiss(animated: true, completion: nil) // dismiss after select place
        
    }
    
    func howsTheWeatherThere(placeName:String, coordinate:CLLocationCoordinate2D ) {
        destinationReverseGeocodeCoordinate(placeName: placeName, coordinate: coordinate)
        
        self.destinationWeatherView.isHidden = false
        
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
            //print("SCREEEEEEEEEAM")
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
                //print("ERROR!!!!")
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
                print(datos["temperature"] ?? "--")
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
                    
                    self.weatherCode = NumberFormatter().number(from: "\(weather[0]["id"]!)") as! Int!
                    //print(weather[0])
                    if self.isNearbyCalled == false {
                        self.isNearbyCalled = true
                        self.myNearByPlaces(coordinates: coordinates, weathercode:self.weatherCode)
                    }
                    
                    
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
                
                self.pressureText = "\(hPa) hPa"
                self.humidityText = "\(NSNumber(value: (results["main"]?["humidity"]) as! Double))%"
            })
            
            }.resume()
        
    }
    
    func closeWeatherDetails(){
        self.destinationWeatherView.isHidden = true
        self.mapView.frame = CGRect(x: 0, y: 0, width: self.mapView.frame.width, height: self.screenSize.height)
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
                
                let kelvin = results["main"]?["temp"] as! Double
                let celsius = round(kelvin - 273.15)
                
                let hPa = results["main"]?["pressure"] as! Double
                
                let pressure = round(hPa / 1013.25)
                //let doubleStr = String(format: "%.2f", pressure) // "3.14"
                self.destinationWeatherView.temperatureLabel.text = "Temperature: \(NSNumber(value: celsius))ºC"
                self.destinationWeatherView.humidityLabel.text = "Humidity: \(NSNumber(value: (results["main"]?["humidity"]) as! Double))%"
                self.destinationWeatherView.pressureLabel.text = "Pressure: \(hPa) hPa"
            })
            
            }.resume()
        
    }
    
    func drawRoute(originName:[String], destinationName:[String]) {
        
        let originFirst = originName.first?.replace(target:" ", withString:"+").replace(target:"#", withString:"")
        let originLast = originName.last?.replace(target:" ", withString:"+")
        //print("Origin: \((originFirst)!)+\((originLast)!)")
        let originString = "\((originFirst)!)+\((originLast)!)"
        
        let destinationFirst = destinationName.first?.replace(target:" ", withString:"+").replace(target:"#", withString:"")
        let destinationLast = destinationName.last?.replace(target:" ", withString:"+")
        //print("Destination: \((destinationFirst)!)+\((destinationLast)!)")
        let destinationString = "\((destinationFirst)!)+\((destinationLast)!)"
        
        var directionsURLString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(originString)&destination=\(destinationString)&travel_mode=driving&key=AIzaSyCURYbqKNf1E9oizVol7flWmxB0Rt5b-PA"
        //print(directionsURLString)
        
        directionsURLString = directionsURLString.addingPercentEscapes(using: String.Encoding.utf8)!
        let directionsURL = NSURL(string: directionsURLString)
        
        DispatchQueue.main.async(execute: {
            let directionsData = NSData(contentsOf: directionsURL! as URL)
            do {
                let json = try JSONSerialization.jsonObject(with: directionsData as! Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>
                
                let status = json["status"] as! String
                
                if status == "OK" {
                    var routes = (json["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                    //let overviewPolyline = routes["overview_polyline"] as! Dictionary<String, AnyObject>
                    let legs = routes["legs"] as! Array<Dictionary<String, AnyObject>>
                    
                    let steps = legs[0]["steps"] as! Array<Dictionary<String, AnyObject>>
                    
                    for step in steps {
                        //print(step["polyline"]?["points"])
                        let route = step["polyline"]?["points"] as! String
                        
                        let path: GMSPath = GMSPath(fromEncodedPath: route)!
                        let routePolyline = GMSPolyline(path: path)
                        routePolyline.map = self.mapView
                        routePolyline.strokeColor = UIColor(red: 44/255, green: 134/255, blue: 200/255, alpha:1)
                        routePolyline.strokeWidth = 4.0
                        
                    }
                    /*
                     let route = overviewPolyline["points"] as! String
                     
                     let path: GMSPath = GMSPath(fromEncodedPath: route)!
                     let routePolyline = GMSPolyline(path: path)
                     routePolyline.map = self.mapView
                     routePolyline.strokeColor = UIColor(red: 44/255, green: 134/255, blue: 200/255, alpha:1)
                     routePolyline.strokeWidth = 3.0
                     */
                }
                
            } catch {
                print("catch")
            }
        })
    }
    
    func destinationReverseGeocodeCoordinate(placeName: String, coordinate: CLLocationCoordinate2D) {
        
        // 1
        let geocoder = GMSGeocoder()
        // 2
        geocoder.reverseGeocodeCoordinate(coordinate){ response, error in
            if let address = response?.firstResult() {
                let responseString = address.lines as! [String]
                //print(responseString)
                
                self.originReverseGeocodeCoordinate(destinationName: responseString)
                
                self.destinationWeatherView.locationLabel.text = "\(placeName), \((responseString.last)!)"
            }
        }
    }
    
    func originReverseGeocodeCoordinate(destinationName: [String]) {
        
        // 1
        let geocoder = GMSGeocoder()
        // 2
        geocoder.reverseGeocodeCoordinate((locationManager.location?.coordinate)!){ response, error in
            if let address = response?.firstResult() {
                let responseString = address.lines as! [String]
                //print(responseString)
                self.drawRoute(originName:(responseString), destinationName:(destinationName))
                
            }
        }
    }
    
    func myNearByPlaces(coordinates:CLLocationCoordinate2D, weathercode:Int) {
        
        var places = [String]()
        
        if weatherCode == 800 {
            places = weatherPlaces["sunny"]!
        }
        
        if weatherCode > 800 && weatherCode < 900 {
            places = weatherPlaces["cloudy"]!
        }
        
        if (weatherCode >= 900 && weatherCode < 1000) || (weatherCode >= 500 && weatherCode < 600) || (weatherCode >= 200 && weatherCode < 400) {
            places = weatherPlaces["rainy"]!
        }
        
        for placeType in places {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Place_type")
            
            request.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(request)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        
                        if (result.value(forKey: "type") as! String) == placeType {
                            result.setValue(true, forKey: "isSelected")
                            //print(placeType)
                        }
                    }
                } else {
                    print("No results")
                }
                
            } catch {
                print("Couldn't fetch results")
            }
            
            var placesURLString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinates.latitude),\(coordinates.longitude)&radius=1000&type=\(placeType)&key=AIzaSyCURYbqKNf1E9oizVol7flWmxB0Rt5b-PA"
            
            placesURLString = placesURLString.addingPercentEscapes(using: String.Encoding.utf8)!
            let placesURL = NSURL(string: placesURLString)
            
            DispatchQueue.main.async(execute: {
                let placesData = NSData(contentsOf: placesURL! as URL)
                do {
                    let json = try JSONSerialization.jsonObject(with: placesData as! Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>
                    
                    let status = json["status"] as! String
                    self.placesMarkers["\(placeType)"] = [GMSMarker]()
                    if status == "OK" {
                        let results = (json["results"] as! Array<Dictionary<String, AnyObject>>)
                        
                        for place in results {
                            let geometry = place["geometry"]?["location"] as! Dictionary<String, AnyObject>
                            let lat = geometry["lat"]?.doubleValue
                            let lng = geometry["lng"]?.doubleValue
                            
                            let position = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
                            let marker = GMSMarker(position: position)
                            
                            if placeType == "cafe" {
                                marker.icon = UIImage(named: "coffe")
                            }
                            marker.title = "\(place["name"] as! String)"
                            self.placesMarkers["\(placeType)"]?.append(marker)
                            self.placesMarkers["\(placeType)"]?.last?.map = self.mapView
                            //marker.map = self.mapView
                        }
                        //print(self.placesMarkers)
                    }
                    
                } catch {
                    print("catch")
                }
            })
        }
        
    }
}
