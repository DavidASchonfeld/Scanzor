//
//  TrophyScreenViewController.swift
//  Scanzor
//
//  Created by David Schonfeld and Scott Hodnefield on 11/19/17.
//  Copyright © 2017 feld. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "theCell"

class TrophyScreenViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  
  @IBOutlet weak var trophyCollectionView: UICollectionView!
  
  
  var speciesInfoArray = [SpeciesInfo]()
  
  //Brian Advent for Core Data methods (http://www.brianadvent.com/build-simple-core-data-driven-ios-app/)
  var moc:NSManagedObjectContext! //MOC stands for ManagedObjectContext, the object that is in charge of the interaction between your code and the Core Data database
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    trophyCollectionView.dataSource = self
    trophyCollectionView.delegate = self
    
    trophyCollectionView.backgroundColor = UIColor.clear
    
    //Load from Core Data
    //From BrianAdvent (http://www.brianadvent.com/build-simple-core-data-driven-ios-app/)
    moc = appDelegate.persistentContainer.viewContext
    
    //Load Variables
    let speciesInfoRequest:NSFetchRequest<SpeciesInfo> = SpeciesInfo.fetchRequest()
    speciesInfoArray = [SpeciesInfo]()
    do {
      try speciesInfoArray = moc.fetch(speciesInfoRequest)
    } catch {
      print("ERROR - Core Data - Could not load data")
    }
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to register cell classes
    //trophyCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using [segue destinationViewController].
   // Pass the selected object to the new view controller.
   }
   */
  
  // MARK: - UICollectionViewDataSource
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return speciesInfoArray.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "theCell", for: indexPath) as! ActualTrophyCollectionViewCell
    
    // Configure the cell
    
    if speciesInfoArray[indexPath.row].capturedCount > 0 {
      cell.creatureImage.image = UIImage(named: speciesInfoArray[indexPath.row].imageName!)
      
      cell.creatureName.text = speciesInfoArray[indexPath.row].name
      cell.creatureCount.text = "Captured: "+String(speciesInfoArray[indexPath.row].capturedCount)
      
    } else {
      //That creature has not been found yet
      cell.creatureName.text = "???"
      //cell.creatureImage.image = UIImage(named: "test")
      cell.creatureImage.image = UIImage(named: speciesInfoArray[indexPath.row].imageName!)
      cell.creatureImage.image = cell.creatureImage.image!.withRenderingMode(.alwaysTemplate)
      cell.creatureImage.tintColor = UIColor.black
      cell.creatureCount.text = ""
    }
   
    
    return cell
  }
  
  // MARK: - UICollectionViewDelegate
  
  /*
   // Uncomment this method to specify if the specified item should be highlighted during tracking
   override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
   return true
   }
   */
  
  /*
   // Uncomment this method to specify if the specified item should be selected
   override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
   return true
   }
   */
  
  /*
   // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
   override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
   return false
   }
   
   override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
   return false
   }
   
   override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
   
   }
   */
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}
