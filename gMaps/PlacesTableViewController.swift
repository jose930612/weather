//
//  PlacesTableViewController.swift
//  gMaps
//
//  Created by Jose Mejia on 5/6/17.
//  Copyright © 2017 ITink. All rights reserved.
//

import UIKit
import CoreData

class PlaceTypeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var placeTagLabel: UILabel!
    @IBOutlet weak var checkTagIcon: CheckButtonView!
}

class PlacesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var placesArray = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Place_type")
        
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    self.placesArray.append(result)
                }
                
            } else {
                print("No results")
            }
            
        } catch {
            print("Couldn't fetch results")
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var numberOfRows:Int!
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Place_type")
        
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            numberOfRows = results.count
            
        } catch {
            print("Couldn't fetch results")
        }
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "place_type", for: indexPath) as! PlaceTypeTableViewCell
        
        //let cell = CustomCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        
        cell.placeTagLabel.text = placesArray[indexPath.row].value(forKey: "type") as? String
        
        //print("\(placesArray[indexPath.row].value(forKey: "isSelected") as! Int)")
        
        if placesArray[indexPath.row].value(forKey: "isSelected") as! Bool == true {
            
            cell.checkTagIcon.isActive = true
            cell.checkTagIcon.fillColor = UIColor(red:0.23, green:0.78, blue:0.44, alpha:1.0)
            cell.checkTagIcon.strokeColor = UIColor(red:0.23, green:0.78, blue:0.44, alpha:1.0)
        }else{
            
            cell.checkTagIcon.isActive = false
            cell.checkTagIcon.fillColor = UIColor(red:0.23, green:0.78, blue:0.44, alpha:0.0)
            cell.checkTagIcon.strokeColor = UIColor(red:0.48, green:0.47, blue:0.47, alpha:1.0)
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Place_type")
        
        let cell = tableView.cellForRow(at: indexPath) as! PlaceTypeTableViewCell
        
        if cell.checkTagIcon.isActive == true {
            
            do {
                let results = try context.fetch(request)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        
                        if (result.value(forKey: "type") as! String) == cell.placeTagLabel.text {
                            result.setValue(false, forKey: "isSelected")
                            //print(placeType)
                        }
                    }
                } else {
                    print("No results")
                }
                
            } catch {
                print("Couldn't fetch results")
            }
            
            cell.checkTagIcon.isActive = false
            cell.checkTagIcon.fillColor = UIColor(red:0.23, green:0.78, blue:0.44, alpha:0.0)
            cell.checkTagIcon.strokeColor = UIColor(red:0.48, green:0.47, blue:0.47, alpha:1.0)
            
        }else{
            
            do {
                let results = try context.fetch(request)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        
                        if (result.value(forKey: "type") as! String) == cell.placeTagLabel.text {
                            result.setValue(false, forKey: "isSelected")
                            //print(placeType)
                        }
                    }
                } else {
                    print("No results")
                }
                
            } catch {
                print("Couldn't fetch results")
            }
            
            cell.checkTagIcon.isActive = true
            cell.checkTagIcon.fillColor = UIColor(red:0.23, green:0.78, blue:0.44, alpha:1.0)
            cell.checkTagIcon.strokeColor = UIColor(red:0.23, green:0.78, blue:0.44, alpha:1.0)
            
        }
        
    }
    /*
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */
    @IBAction func doneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
