//
//  InventoryViewController.swift
//  Scanzor
//
//  Created by David Schonfeld and Scott Hodnefield on 9/29/17.
//  Copyright © 2017 feld. All rights reserved.
//

// We used the following website for reference regarding scanning barcodes. (https://www.appcoda.com/simple-barcode-reader-app-swift/)

import Foundation
import UIKit
import AVFoundation
import CoreData

var theSession: AVCaptureSession!
var thePreviewLayer: AVCaptureVideoPreviewLayer!

class CameraScreenViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate{
  
  var metadataOutput = AVCaptureMetadataOutput()
  var theVideoOutput: AVCaptureDeviceInput?
  
  var barcodeToSend: String = ""
  
  
  @IBOutlet weak var button_MainMenu: UIButton!
  @IBOutlet weak var button_Collection: UIButton!
  
  @IBOutlet weak var imageView_tutorialArrow: UIImageView!
  @IBOutlet weak var label_instructions: UILabel!
  
  @IBOutlet weak var label_givePermission_instructions: UILabel!
  @IBOutlet weak var labelForButton_goToAppSettings: UIButton!
  
  @IBAction func button_goToAppSettings(_ sender: UIButton) {
    
    
    // The following line is from this website (https://stackoverflow.com/questions/25988241/url-scheme-open-settings-ios)
    UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
  }
  
  
  //Core Data Objects
  //From BrianAdvent (http://www.brianadvent.com/build-simple-core-data-driven-ios-app/)
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  var moc:NSManagedObjectContext! //MOC stands for ManagedObjectContext, the object that is in charge of the interaction between your code and the Core Data database
  var savedBarcodeObjectArray = [SavedBarcode]()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //Initializing CoreData's MOC
    //From BrianAdvent (http://www.brianadvent.com/build-simple-core-data-driven-ios-app/)
    moc = appDelegate.persistentContainer.viewContext
    
    //Code to check if tutorial has completed,
    //And showing/hiding the tutorial arrow
    let defaults = UserDefaults.standard
    let defaultsDict = defaults.dictionaryRepresentation()
    if (defaultsDict["tutorial"] == nil) {
      imageView_tutorialArrow.isHidden = false
      button_MainMenu.isEnabled = false
      button_Collection.isEnabled = false
    } else {
      imageView_tutorialArrow.isHidden = true
      button_MainMenu.isEnabled = true
      button_Collection.isEnabled = true
    }
    
    
    //Handling Permissions (and then, setting up the Camera)
    self.label_givePermission_instructions.text = "Waiting for popup window response."
    
    if (AVCaptureDevice.authorizationStatus(for: .video) == .restricted || AVCaptureDevice.authorizationStatus(for: .video) == .denied){
      cameraDeniedSetup()
      return
    }
    else if (AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined){
  
      //Source (https://stackoverflow.com/questions/27646107/how-to-check-if-the-user-gave-permission-to-use-the-camera)
      AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
        if granted {
          //Access Allowed
          self.turnOnCamera()
          
        } else {
          //Access Denied
          self.cameraDeniedSetup()
        }
      })
      
    }
    else if (AVCaptureDevice.authorizationStatus(for: .video) == .authorized){
      label_givePermission_instructions.text = "Please wait. The camera is loading."
      self.turnOnCamera()
    } else {
      //This should never occur
    }
    
    
  }
  
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  func cameraDeniedSetup(){
    
    //Source: https://stackoverflow.com/questions/46218270/swift-4-must-be-used-from-main-thread-only-warning
    DispatchQueue.main.async{
      self.label_givePermission_instructions.text = "Please click below to allow this app to access your camera."
      self.labelForButton_goToAppSettings.isEnabled = true
    }
  }
  
  
  func turnOnCamera(){
    
    //I am explictly turning on the camera on the main thread because editing the layers and .views are required to be in the main thread, and their code does nothing if it is not in the main thread (and is displayed as a purple error in Xcode)
    DispatchQueue.main.async{
      self.label_givePermission_instructions.text = "Please wait. The camera is loading."
      self.labelForButton_goToAppSettings.isEnabled = false
    
    
    theSession = AVCaptureSession()
    
    let theVideoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)
    
    do {
      self.theVideoOutput = try AVCaptureDeviceInput(device: theVideoCaptureDevice!)
    } catch {
      return
    }
    
      if (theSession.canAddInput(self.theVideoOutput!)){
      theSession.addInput(self.theVideoOutput!)
    } else {
      self.scanningNotPossible()
    }
    
    // Create output object.
    self.metadataOutput = AVCaptureMetadataOutput()
    
    // Add output to the session.
    if (theSession.canAddOutput(self.metadataOutput)) {
      theSession.addOutput(self.metadataOutput)
      
      // Send captured data to the delegate object via a serial queue.
      self.metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      
      // Set barcode type for which to scan: EAN-13.
      self.metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.ean13]
      
    } else {
      self.scanningNotPossible()
    }
    
    
      // Add previewLayer and have it show the video data.
      thePreviewLayer = AVCaptureVideoPreviewLayer(session: theSession)
      thePreviewLayer.frame = self.view.layer.bounds
      thePreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
      self.view.layer.addSublayer(thePreviewLayer)
    
   
    
      // Begin the capture session.
    
      theSession.startRunning()
      
      //Put buttons on top of camera
      self.view.bringSubview(toFront: self.button_MainMenu)
      self.view.bringSubview(toFront: self.button_Collection)
      self.view.bringSubview(toFront: self.label_instructions)
      self.view.bringSubview(toFront: self.imageView_tutorialArrow)
      
      
      
    }
  }
  
  
  func scanningNotPossible(){
    let theAlert = UIAlertController(title: "Can't scan", message: "Your device can't scan", preferredStyle: .alert)
    theAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    present(theAlert, animated: true, completion: nil)
    theSession = nil
  }
  
  
  func barcodeDetected(dataFromPhysicalBarcode: String) {
    
    // We used the following website for reference (https://www.appcoda.com/simple-barcode-reader-app-swift/)
    // Remove the spaces.
    let trimmedCode = dataFromPhysicalBarcode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
    // EAN or UPC? - Check for added "0" at beginning of code.
    let trimmedCodeString = "\(trimmedCode)"
    var trimmedCodeNoZero: String
    
    barcodeToSend = ""
    if trimmedCodeString.hasPrefix("0") && trimmedCodeString.characters.count > 1 {
      trimmedCodeNoZero = String(trimmedCodeString.characters.dropFirst())
      barcodeToSend = trimmedCodeNoZero
    } else {
      barcodeToSend = trimmedCodeString
    }
    
    if (checkForBarcodeRepeat(inBarcode: Int64(barcodeToSend)!)){
      //Barcode Already Scanned in the Past
      
      //Popup
      let alert = UIAlertController(title: "Barcode Already Scanned", message: "", preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.destructive, handler: { action in
        self.navigationController?.popViewController(animated: true)
        
        theSession.startRunning()
        
      }))
      self.present(alert, animated: true, completion: nil)
      
      
    } else {
      //New Barcode
      self.performSegue(withIdentifier: "from_CameraScreen_To_SingleCreature", sender: self)
    }
    
  }
  
  
  
  
  
  
  
  
  func metadataOutput(_ output: AVCaptureMetadataOutput,
                      didOutput metadataObjects: [AVMetadataObject],
                      from connection: AVCaptureConnection){
    //  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
    
    
    /*  func captureOutput(_ output: AVCaptureOutput!,
     didOutput sampleBuffer: [AnyObject]!,
     from connection: AVCaptureConnection){
     */
    //  func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
    print("CAPTURE OUTPUT!!!!")
    //  func metadataOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!){
    
    // Get the first object from the metadataObjects array.
    if let barcodeData = metadataObjects.first {
      
      
      
      
      
      
      //    if let barcodeData = sampleBuffer.first {
      //    var barcodeData = sampleBuffer
      //    if var barcodeData = sampleBuffer {
      
      
      
      
      // Turn it into machine readable code
      let barcodeReadable = barcodeData as? AVMetadataMachineReadableCodeObject;
      if let readableCode = barcodeReadable {
        // Send the barcode as a string to barcodeDetected()
        barcodeDetected(dataFromPhysicalBarcode: readableCode.stringValue!);
      }
      
      // Vibrate the device to give the user some feedback.
      AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
      
      // Avoid a very buzzy device.
      theSession.stopRunning()
      //    }
      
      
      
    }
  }
  override func viewWillAppear(_ animated: Bool){
    
    super.viewWillAppear(animated)
    if (theSession?.isRunning == false) {
      theSession.startRunning()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool){
    super.viewWillDisappear(animated)
    
    if (theSession?.isRunning == true) {
      theSession.stopRunning()
    }
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    
    print("PREPARE METHOD RUNNING")
    
    //This if statement is from: https://www.appcoda.com/simple-barcode-reader-app-swift/
    if (theSession?.isRunning == true) {
      theSession.stopRunning()
      theSession.removeInput(theVideoOutput!)
    }
    
    
    if(segue.identifier == "from_CameraScreen_To_SingleCreature"){
      if let newVC = segue.destination as? SingleCreatureViewController {
        newVC.barcodeReceivedFromPreviousViewController = barcodeToSend
        newVC.vc_Status = "Create"
      }
//      from_Camera_to_Main
//      from_Camera_to_Inventory
      
    }
    
    
  }
  
//   NOT BEING USED FOR NOW
//  func processBarcode(inBarcode: Int64){
//
//    if (checkForBarcodeRepeat(inBarcode: inBarcode)){
//      //Barcode Already Scanned in the Past
//
//    } else {
//      //New Barcode
//      self.performSegue(withIdentifier: "from_CameraScreen_To_SingleCreature", sender: self)
//    }
//
//
//  }
//
  
  
  func checkForBarcodeRepeat(inBarcode: Int64) -> Bool {
    
    let barcodeRequest:NSFetchRequest<SavedBarcode> = SavedBarcode.fetchRequest()
    let barcode_sortDescriptor = NSSortDescriptor(key: "barcodeOrigin", ascending: true)
    barcodeRequest.sortDescriptors = [barcode_sortDescriptor]
    do {
      try savedBarcodeObjectArray = moc.fetch(barcodeRequest)
    } catch {
      print("ERROR - Core Data - Could not load data")
    }
    print("START comparing")
    for barcodeObjectIter in savedBarcodeObjectArray {
      print("IN: \(inBarcode), DB: \(barcodeObjectIter.barcodeOrigin)")
      if (inBarcode == barcodeObjectIter.barcodeOrigin){
        return true
      }
    }
    return false
    
    
  }
  
  // Helpful Develpment Function - Prints Camera Permission
  func printCameraPermissions(){
    if (AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined){
      print ("CAMERA PERMISSION: NOT DETERMINED")
    }
    if (AVCaptureDevice.authorizationStatus(for: .video) == .restricted){
      print ("CAMERA PERMISSION: RESTRICTED")
    }
    if (AVCaptureDevice.authorizationStatus(for: .video) == .denied){
      print ("CAMERA PERMISSION: denied")
    }
    if (AVCaptureDevice.authorizationStatus(for: .video) == .authorized){
      print ("CAMERA PERMISSION: authorized")
    }
  }
  
//  func printCameraPermissions(){
//  //https://stackoverflow.com/questions/27646107/how-to-check-if-the-user-gave-permission-to-use-the-camera
//
//    if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
//      //We ARE allowed to use the camera
//    } else {
//    AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool)
//      if granted {
//        print("access allowed")
//      else {
//        print("Access denied")
//      }
//      })
//    }
//    }
//  }
  
  
  
  
  
  
}
