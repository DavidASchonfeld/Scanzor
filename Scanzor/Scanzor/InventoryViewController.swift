//
//  InventoryViewController.swift
//  Scanzor
//
//  Created by David Schonfeld and Scott Hodnefield on 9/29/17.
//  Copyright © 2017 feld. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class InventoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var tableView_Creatures: UITableView!
  var tableView_array_Creatures: [SavedCreature] = []
  var indexOfCreatureToPass = 0
  
  @IBOutlet weak var button_capture: UIButton!
  
  @IBOutlet weak var imageView_tutorialArrow: UIImageView!
  
  @IBAction func action_mainMenu(_ sender: UIButton) {
    //NOTE: This will happen IN ADDITION to the OTHER ACTION
    //connected to the SAME BUTTON, which redirects to Main Menu
    //by adding it to the windows stack
    let defaults = UserDefaults.standard
    let defaultsDict = defaults.dictionaryRepresentation()
    
    var tutorialValue = String(describing: defaultsDict["tutorial"])
    if (defaultsDict["tutorial"] == nil){
      defaults.set("Penultimate", forKey: "tutorial")
    }
    
  }
  
  
  //CORE DATA VARIABLES
  //Brian Advent
  var moc:NSManagedObjectContext! //MOC stands for ManagedObjectContext, the object that is in charge of the interaction between your code and the Core Data database
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  
  
  
  func tableView_Creatures_loadData(){
    print ("tableView_Creatures_loadData()")
    //TODO: eventually, this will load from a database
//    for i in (0...25) {
//      tableView_array_Creatures.append(Creature(name: "SuperCodePython_"+String(i), picture: UIImage(named: "test")!, dateCaptured: "Friday, September 29", barcodeOrigin: 234592345))
//    }
//
//    // 1 Gecko
//    tableView_array_Creatures.append(Creature(name: "Cobra King", picture: UIImage(named: "lizard")!, tint: UIColor.init(red: 0, green: 0, blue: 0, alpha: 0), dateCaptured: "Tuesday, October 24", barcodeOrigin: 000000000))
//
//    // 3 Birds
//
//    tableView_array_Creatures.append(Creature(name: "Toucan Do It - Grayscale", picture: UIImage(named: "bird-grayscale")!, tint: UIColor.init(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.0), dateCaptured: "Tuesday, October 24", barcodeOrigin: 111111111))
//    tableView_array_Creatures.append(Creature(name: "TINT - RED", picture: UIImage(named: "bird-grayscale")!, tint: UIColor.init(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.2), dateCaptured: "Tuesday, October 24", barcodeOrigin: 222222222))
//    tableView_array_Creatures.append(Creature(name: "TINT - GREEN", picture: UIImage(named: "bird-grayscale")!, tint: UIColor.init(red: 0/255, green: 255/255, blue: 0/255, alpha: 0.2), dateCaptured: "Tuesday, October 24", barcodeOrigin: 333333333))
//    tableView_array_Creatures.append(Creature(name: "TINT - BLUE", picture: UIImage(named: "bird-grayscale")!, tint: UIColor.init(red: 0/255, green: 0/255, blue: 255/255, alpha: 0.2), dateCaptured: "Tuesday, October 24", barcodeOrigin: 444444444))
//
    //0.2
    
    
    let creatureRequest:NSFetchRequest<SavedCreature> = SavedCreature.fetchRequest()
    
    //NOTE: No sorting for now
    //Sorted by descending order
    //let creature_sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
    //creatureRequest.sortDescriptors = [creature_sortDescriptor]
    
    var temp_savedCreatureArray = [SavedCreature]()
    
    do {
      try temp_savedCreatureArray = moc.fetch(creatureRequest)
    } catch {
      print("ERROR - Core Data - Could not load data")
    }
    
    //Display the database data to the user
    for oneCreature in temp_savedCreatureArray {
      tableView_array_Creatures.append(oneCreature)
      print("oneCreature: \(oneCreature.name)")
    }
    
    
    tableView_Creatures.reloadData()
  }
  
  
  
  //From David's Lab4 code from CSE438 Mobile Development
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    print ("GET TABLE COUNT")
    return tableView_array_Creatures.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    print ("GET TABLE CELL")
    let myCell = tableView.dequeueReusableCell(withIdentifier: "theTableCell", for: indexPath) as! ActualInventoryTableViewCell
    //This line doesn't work with custom cells
//    let myCell = UITableViewCell(style: .default, reuseIdentifier: "theTableCell") as! ActualInventoryTableViewCell
    if (tableView_array_Creatures[indexPath.row].tint == "No Tint"){
      myCell.creatureName?.text = tableView_array_Creatures[indexPath.row].name
    } else {
      myCell.creatureName?.text = tableView_array_Creatures[indexPath.row].tint! + " " + tableView_array_Creatures[indexPath.row].name!
    }
    
    myCell.creatureImage?.image = UIImage(named: tableView_array_Creatures[indexPath.row].picture!)
    
    //let tempOverlayImage = tableView_array_Creatures[indexPath.row].picture!
    //tempOverlayImage.tintColor = UIColor.blue.withAlphaComponent(0.2)
    myCell.overlayedCreatureImage?.image = UIImage(named:tableView_array_Creatures[indexPath.row].picture!)
    
    let currentCreature = tableView_array_Creatures[indexPath.row]
    if (currentCreature.tint == "No Tint"){
      myCell.overlayedCreatureImage?.isHidden = true
    } else {
      //There IS a tint
      var colorDict = [
        "White": UIColor.white,
        "Red": UIColor.red,
        "Orange": UIColor.orange,
        "Yellow":UIColor.yellow,
        "Green":UIColor.green,
        "Blue":UIColor.blue,
        "Purple":UIColor.purple,
        "Black":UIColor.black
      ]
      let tintedImage = myCell.overlayedCreatureImage?.image!.withRenderingMode(.alwaysTemplate)
      myCell.overlayedCreatureImage?.image = tintedImage
      myCell.overlayedCreatureImage?.tintColor = colorDict[currentCreature.tint!] //Alpha (Transparency) is set on the Storyboard on UIImage_creatureTint
      myCell.overlayedCreatureImage?.isHidden = false
    }
    
    
    
    
    
    
    myCell.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    return myCell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    indexOfCreatureToPass = indexPath.row
    self.performSegue(withIdentifier: "from_Inventory_to_SingleCreature", sender: self)
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if(segue.identifier == "from_Inventory_to_SingleCreature"){
      if let newVC = segue.destination as? SingleCreatureViewController {
//        newVC.barcodeId = String(tableView_array_Creatures[indexOfCreatureToPass].barcodeOrigin)
//        newVC.name = tableView_array_Creatures[indexOfCreatureToPass].name
//        newVC.creaturePicture = tableView_array_Creatures[indexOfCreatureToPass].picture
//        newVC.creatureTint = tableView_array_Creatures[indexOfCreatureToPass].tint
        
        
        newVC.currentCreature = tableView_array_Creatures[indexOfCreatureToPass]
        //TODO: Pass the rest of the variables.
        
        
        
        
        newVC.vc_Status = "Inventory"
      }
      
      
    }
    
    
  }
  
  
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    print ("VIEW DID LOAD")
    tableView_Creatures.dataSource = self
    tableView_Creatures.delegate = self
    tableView_Creatures.reloadData()
    
    //From BrianAdvent
    moc = appDelegate.persistentContainer.viewContext
    
    //LOAD TUTORIAL
    //Code to check if tutorial has completed,
    //And showing/hiding the tutorial arrow
    let defaults = UserDefaults.standard
    let defaultsDict = defaults.dictionaryRepresentation()
    if (defaultsDict["tutorial"] == nil) {
      imageView_tutorialArrow.isHidden = false
      button_capture.isEnabled = false
    } else {
      imageView_tutorialArrow.isHidden = true
      button_capture.isEnabled = true
    }
    
    
    //Possibly needed possibly take out
//    self.tableView_Creatures.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
    print ("VIEW WILL APPEAR")
   tableView_Creatures_loadData()
    tableView_Creatures.reloadData()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
  
}

