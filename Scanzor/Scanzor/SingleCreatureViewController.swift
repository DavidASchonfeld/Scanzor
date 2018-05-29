//
//  SingleCreatureViewController.swift
//  Scanzor
//
//  Created by David Schonfeld and Scott Hodnefield and on 10/13/17.
//  Copyright © 2017 feld. All rights reserved.
//
// Tinting code comes from
// https://stackoverflow.com/questions/19274789/how-can-i-change-image-tintcolor-in-ios-and-watchkit

import Foundation
import UIKit
import CoreData

class SingleCreatureViewController: UIViewController {
  
  var vc_Status: String = ""
  var barcodeReceivedFromPreviousViewController: String = ""
  var currentCreature: SavedCreature!
  
  @IBOutlet weak var label_barcode: UILabel!
  @IBOutlet weak var label_name: UILabel!
  @IBOutlet weak var UIImage_creaturePic: UIImageView!
  @IBOutlet weak var UIImage_creatureTint: UIImageView!
  
  @IBOutlet weak var imageView_tutorialArrow: UIImageView!
  
  
  var savedCreatureArray = [SavedCreature]()
  var savedBarcodeObjectArray = [SavedBarcode]()
  var speciesInfoArray = [SpeciesInfo]()
  
  //Brian Advent
  var moc:NSManagedObjectContext! //MOC stands for ManagedObjectContext, the object that is in charge of the interaction between your code and the Core Data database

  let appDelegate = UIApplication.shared.delegate as! AppDelegate

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    //From BrianAdvent
    moc = appDelegate.persistentContainer.viewContext
    
    //LOAD VARIABLES
    let speciesInfoRequest:NSFetchRequest<SpeciesInfo> = SpeciesInfo.fetchRequest()
    speciesInfoArray = [SpeciesInfo]()
    do {
      try speciesInfoArray = moc.fetch(speciesInfoRequest)
    } catch {
      print("ERROR - Core Data - Could not load data")
    }
    
    // LOAD VIEW
    //Eventually process things diferrently depending on screen that leads to this page
    if(vc_Status=="Create"){
        //If we are coming from the camera screen
      print("ORIGIN: Camera Screen")
      currentCreature = generateCreature(inBarcode: Int64(barcodeReceivedFromPreviousViewController)!)
      loadCreatureInfoIntoView(inCreature: currentCreature)
      
      saveThatBarcode(inBarcode: Int64(barcodeReceivedFromPreviousViewController)!)
      
      
    } else if (vc_Status=="Inventory"){
      print ("ORIGIN: Inventory")
      print ("NOT creating anything")
      loadCreatureInfoIntoView(inCreature: currentCreature)
    } else {
      print ("ERROR - The previous view controller is unknown")
    }
    
    //CHECK TUTORIAL MODE
    //Code to check if tutorial has completed,
    //And showing/hiding the tutorial arrow
    let defaults = UserDefaults.standard
    let defaultsDict = defaults.dictionaryRepresentation()
    if (defaultsDict["tutorial"] == nil) {
      imageView_tutorialArrow.isHidden = false
    } else {
      imageView_tutorialArrow.isHidden = true
    }
    
    
  }
  
  func loadCreatureInfoIntoView(inCreature: SavedCreature){
    currentCreature = inCreature
    
    if (inCreature.tint == "No Tint"){
      label_name.text = " "+currentCreature.name!+" " //Adding spacing to the ends for a better looking button
    } else {
      //There is a tint
      label_name.text = " "+inCreature.tint!+" "+currentCreature.name!+" " //Adding spacing to the ends for a better looking button
    }
    
    label_barcode.text = " Barcode of Origin \n "+String(currentCreature.barcodeOrigin)
    UIImage_creaturePic.image = UIImage(named: currentCreature.picture!)

    //Tint the image
    if (currentCreature.tint == "No Tint"){
      UIImage_creatureTint.isHidden = true
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
      var tintedImage = UIImage_creaturePic.image!.withRenderingMode(.alwaysTemplate)
      UIImage_creatureTint.image = tintedImage
      UIImage_creatureTint.tintColor = colorDict[currentCreature.tint!] //Alpha (Transparency) is set on the Storyboard on UIImage_creatureTint
      UIImage_creatureTint.isHidden = false
    }
   
  }
  
  
  
  
  // CORE DATA METHODS
  //http://www.brianadvent.com/build-simple-core-data-driven-ios-app/
  
  
  func generateCreature(inBarcode: Int64) -> SavedCreature {
    var whichSpecies = Int(inBarcode) % speciesInfoArray.count
    print("inBarcode: \(inBarcode), whichSpeciesIndex: \(whichSpecies) out of \(speciesInfoArray.count) possible creatures")
    var creatureGen_speciesInfo = speciesInfoArray[whichSpecies]
    
    var tintArray = [
      "White",
      "Red",
      "Orange",
      "Yellow",
      "Green",
      "Blue",
      "Purple",
      "Black"
    ]
    
    var whichTint = ""
    var tintDeterminer = Int(inBarcode) % (tintArray.count*2)
    print("tintDeterminer: \(tintDeterminer), tintArray.count: \(tintArray.count)")
    if(tintDeterminer<tintArray.count){
      //Add a tint
      whichTint = tintArray[tintDeterminer]
    } else {
      //Designate no tint
      whichTint = "No Tint"
    }
    
    
    //From BrianAdvent
    let creatureItem = SavedCreature(context: moc)
    creatureItem.name = creatureGen_speciesInfo.name
    creatureItem.picture = creatureGen_speciesInfo.imageName
    creatureItem.barcodeOrigin = inBarcode
    creatureItem.tint = whichTint
    
    //Save the creature
    appDelegate.saveContext()
    
    
    //Increment the creatureCount for that specific species in the SpeciesInfo CoreData entry
    //https://www.youtube.com/watch?v=nHSGrqyTGZ0
    let speciesInfoRequest:NSFetchRequest<SpeciesInfo> = SpeciesInfo.fetchRequest()
    
    do {
      var speciesInfoToEditArray = try moc.fetch(speciesInfoRequest)
      if (speciesInfoArray.count <= 0){
        print("ERROR - SpeciesInfoArray Size <= 0")
      }
      for speciesInfoEntry in speciesInfoToEditArray as [NSManagedObject]{
        if (creatureItem.name == (speciesInfoEntry.value(forKey: "name") as? String)) {
          var capturedCount = speciesInfoEntry.value(forKey: "capturedCount") as? Int
          speciesInfoEntry.setValue(capturedCount!+1, forKey: "capturedCount")
          print("CapturedCount| Species:\(creatureItem.name) BEFORE: \(capturedCount), AFTER: \(capturedCount!+1)")
          self.appDelegate.saveContext()
        }
      }
      
    } catch {
      print("ERROR - Core Data - Could not load data")
    }
    
    return creatureItem
  }
  
  
  
  //Built by refering to Brian Advent's Tutorial on CoreData
  func saveThatBarcode(inBarcode: Int64){
    let barcodeItem = SavedBarcode(context: moc)
    barcodeItem.barcodeOrigin = inBarcode
    appDelegate.saveContext()
    loadCreatureAndBarcodeArraysFromCoreData()
  }
  
  func loadCreatureAndBarcodeArraysFromCoreData(){
    let creatureRequest:NSFetchRequest<SavedCreature> = SavedCreature.fetchRequest()
    
    //Sorted by descending order
    let creature_sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
    creatureRequest.sortDescriptors = [creature_sortDescriptor]
    
    let barcodeRequest:NSFetchRequest<SavedBarcode> = SavedBarcode.fetchRequest()
    let barcode_sortDescriptor = NSSortDescriptor(key: "barcodeOrigin", ascending: true)
    barcodeRequest.sortDescriptors = [barcode_sortDescriptor]
    
    
    do {
      try savedCreatureArray = moc.fetch(creatureRequest)
      try savedBarcodeObjectArray = moc.fetch(barcodeRequest)
    } catch {
        print("ERROR - Core Data - Could not load data")
    }
    
    //Display the database data to the user
    for oneCreature in savedCreatureArray {
      print("Name: \(oneCreature.name), Barcode:\(oneCreature.barcodeOrigin)")
    }
    
    for oneBarcode in savedBarcodeObjectArray {
      print("Barcode List (con) | Barcode:\(oneBarcode.barcodeOrigin)")
    }
  }
  
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
  
  
  
}
