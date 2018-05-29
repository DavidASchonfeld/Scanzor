//
//  ViewController.swift
//  Scanzor
//
//  Created by David Schonfeld and Scott Hodnefield on 9/29/17.
//  Copyright © 2017 feld. All rights reserved.
//
// Source for Rounding Corners in our Storyboard (https://stackoverflow.com/questions/34215320/use-storyboard-to-mask-uiview-and-give-rounded-corners)

import UIKit
import CoreData

class ViewController: UIViewController {

  
  @IBOutlet weak var button_viewCollection: UIButton!
  @IBOutlet weak var button_trophyCase: UIButton!
  
  @IBOutlet weak var imageView_tutorialArrow: UIImageView!
  
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    //Core Data Initialization
    //From BrianAdvent (http://www.brianadvent.com/build-simple-core-data-driven-ios-app/)
    moc = appDelegate.persistentContainer.viewContext
    
    let defaults = UserDefaults.standard
    let defaultsDict = defaults.dictionaryRepresentation()
    
    var tutorialValue = String(describing: defaultsDict["tutorial"])
    print("ViewController: defaultsDict[\"tutorial\"]: \(tutorialValue)")
    
    if (defaultsDict["tutorial"] == nil) {
      print("Enter if - defaultsDict[tutorial] == nil")
      
      imageView_tutorialArrow.isHidden = false
      button_viewCollection.isEnabled = false
      button_trophyCase.isEnabled = false
      
      //Ppopup code for this is in viewDidAppear
      
    } else if (String(describing: defaultsDict["tutorial"]) == "Optional(Penultimate)"){
      //Code for this is in viewDidAppear
      
    } else {
      //defaultsDict[tutorial] == Optional(Done)
      
      imageView_tutorialArrow.isHidden = true
      button_viewCollection.isEnabled = true
      button_trophyCase.isEnabled = true
    }
    
    
    
    if (defaultsDict["firstTimeLoad"] == nil) {
      //First Time Opening the App
      defaults.set(String(describing: "Not nil"), forKey: "firstTimeLoad")
      
      //Iterate through each species to add

      //Load Data into TrophyCase (Species Info)
      
      //Loading up SpeciesInfo Guidebook with information
      //Hard Coded Data
      saveThatSpeciesInfoEntry(inName: "Thunder Bird", inPicName: "bird")
      saveThatSpeciesInfoEntry(inName: "Bonnacon", inPicName: "bull")
      saveThatSpeciesInfoEntry(inName: "Gem Warrior", inPicName: "crystalWarrior")
      saveThatSpeciesInfoEntry(inName: "Kumato", inPicName: "dragonBat")
      saveThatSpeciesInfoEntry(inName: "Kumi", inPicName: "frillLizard")
      saveThatSpeciesInfoEntry(inName: "Typhon", inPicName: "gator")
      saveThatSpeciesInfoEntry(inName: "Goryo", inPicName: "greyGhost")
      saveThatSpeciesInfoEntry(inName: "Tatsu", inPicName: "hornedTiger")
      saveThatSpeciesInfoEntry(inName: "Talos", inPicName: "hulkThing")
      saveThatSpeciesInfoEntry(inName: "Lernaea", inPicName: "hydra")
      saveThatSpeciesInfoEntry(inName: "Alphyn", inPicName: "lion")
      saveThatSpeciesInfoEntry(inName: "Pytho", inPicName: "lizard")
      saveThatSpeciesInfoEntry(inName: "Mahamba", inPicName: "mermanThing")
      saveThatSpeciesInfoEntry(inName: "Arachnus", inPicName: "skitterBug")
      saveThatSpeciesInfoEntry(inName: "Bai Jin", inPicName: "somethingDjinn")
      saveThatSpeciesInfoEntry(inName: "Sphynx", inPicName: "sphynx")
      saveThatSpeciesInfoEntry(inName: "Tripura", inPicName: "spider")
      saveThatSpeciesInfoEntry(inName: "Cambia", inPicName: "spikyLizard")
      saveThatSpeciesInfoEntry(inName: "Orobas", inPicName: "stinger")
      saveThatSpeciesInfoEntry(inName: "Jug Spirit", inPicName: "waterCreature")
      saveThatSpeciesInfoEntry(inName: "Pixis", inPicName: "whiteFairy")
      saveThatSpeciesInfoEntry(inName: "Fafnir", inPicName: "wingSnake")
      saveThatSpeciesInfoEntry(inName: "Huldra", inPicName: "worm")
      
    }
    
   
  }

  
  override func viewDidAppear(_ animated: Bool) {
    //Code to check if tutorial has completed,
    //And showing/hiding the tutorial arrow
    
    // All of the following objects that relate to the tutorial only appear to the user if defaultsDict["tutorial"] == nil OR == Optional(Penultimate)
    var tutorialMessage = "This is an app that lets you use barcodes in real life to collect digital creatures on your phone. Follow the orange arrows to complete the tutorial."
    
    
    let defaults = UserDefaults.standard
    let defaultsDict = defaults.dictionaryRepresentation()
    
    var tutorialValue = String(describing: defaultsDict["tutorial"])
    
    if (defaultsDict["tutorial"] == nil) {
      
      imageView_tutorialArrow.isHidden = false
      button_viewCollection.isEnabled = false
      button_trophyCase.isEnabled = false
      
      let alert = UIAlertController(title: "Welcome!", message: tutorialMessage, preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.destructive, handler: { action in
        self.navigationController?.popViewController(animated: true)
        
      }))
      self.present(alert, animated: true, completion: nil)
      
      
    } else if (String(describing: defaultsDict["tutorial"]) == "Optional(Penultimate)"){
      
      defaults.set(String(describing: "Done"), forKey: "tutorial")
      self.imageView_tutorialArrow.isHidden = true
      self.button_viewCollection.isEnabled = true
      self.button_trophyCase.isEnabled = true
      
      
      //Popup
      //The following website was used for reference for the popup code (https://www.appcoda.com/simple-barcode-reader-app-swift/)
      
      let alert = UIAlertController(title: "Tutorial Complete. Enjoy the app!", message: "", preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.destructive, handler: { action in
        self.navigationController?.popViewController(animated: true)
        
        
        self.imageView_tutorialArrow.isHidden = true
        self.button_viewCollection.isEnabled = true
        self.button_trophyCase.isEnabled = true
        
        let defaults = UserDefaults.standard
        let defaultsDict = defaults.dictionaryRepresentation()
        defaults.set(String(describing: "Done"), forKey: "tutorial")
        
      }))
      self.present(alert, animated: true, completion: nil)
      
      
      
    } else {
      //defaultsDict[tutorial] == Optional(Done)
      print("Enter if - defaultsDict[tutorial] == else")
      
      imageView_tutorialArrow.isHidden = true
      button_viewCollection.isEnabled = true
      button_trophyCase.isEnabled = true
    }
  }
  

  // CORE DATA Functions for This View
  //From BrianAdvent (http://www.brianadvent.com/build-simple-core-data-driven-ios-app/)
  var moc:NSManagedObjectContext! //MOC stands for ManagedObjectContext, the object that is in charge of the interaction between your code and the Core Data database
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  
  func saveThatSpeciesInfoEntry(inName: String, inPicName: String){
    let speciesInfoEntry = SpeciesInfo(context: moc)
    
    speciesInfoEntry.name = inName
    speciesInfoEntry.imageName = inPicName
    
    appDelegate.saveContext()
  }
  
  
  

}
