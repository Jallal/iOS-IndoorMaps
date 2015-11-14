//
//  NavigationMainViewController.swift
//  Whirlpool-iOS
//
//  Created by Jallal Elhazzat on 9/28/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
class  BuildingsMapsViewController : UIViewController , CLLocationManagerDelegate,GMSMapViewDelegate,UIPopoverPresentationControllerDelegate{
    
   //The alert view for notification
    var alertView: UIView = UIView()
    //The button that dismiss the view
    var ok_button : UIButton = UIButton()
    //the message on the notification view
    var  label   : UILabel   = UILabel();
    //The room being passed
    internal var _room = RoomData()
    var CurrentFloor : Int = Int()
    var CurrentBuilding : String = String()
    var  NumberOfFloor  : Int = Int()
    var floors   =  [String]()
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var getDirections: UIButton!
    //origin marker during navigation
    var originMarker: GMSMarker!
    //distination marker for navigation
    var destinationMarker: GMSMarker!
    //The rout between start and end postions
    var routePolyline: GMSPolyline!
    var _building : Building!

   
    
    //internal var Floors = _FloorData
    
    //the picker for the floors
   @IBOutlet weak var floorPicker: UITableView!
    
    
    @IBAction func helpButton(sender: AnyObject) {
        
        self.floorPicker.hidden = !self.floorPicker.hidden
        self.Address.hidden = !self.Address.hidden
        self.getDirections.hidden = !self.getDirections.hidden
        
    }
    
    @IBAction func getDirections(sender: AnyObject) {
      self.mapPin.hidden = !self.mapPin.hidden
        
    }
    // The pin that helps locat the user
    @IBOutlet weak var mapPin: UIImageView!
    //Current location for the user
    @IBOutlet weak var Address: UILabel!
    //The map object
    @IBOutlet weak var mapView: GMSMapView!
    
    let locationManager = CLLocationManager()
    
    //The number of floors in the given building
    
    func populateFloors(){
        
        print("&&&&&&&&&&&&&&&&&&&&&&NUMBER OF FLOORS WE HAVE &&&&&&&&&&&&&&&&&&&&&&&&&&&&")
        print(NumberOfFloor)
        
        var i : Int = 0
        if(self.NumberOfFloor != 0){
        for index  in (1...NumberOfFloor).reverse(){
            floors.append("\(index)")
            i = i+1
        }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.CurrentFloor = 2 // Make sure you fix this later on
        self.floorPicker.tableFooterView = UIView(frame: CGRectZero)
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.mapView.delegate = self
        //the pin to help locat the user
        self.mapPin.hidden = true;
        self.floorPicker.hidden = true
        self.Address.hidden = true
        self.getDirections.hidden = true
        mapPin.userInteractionEnabled = true
        mapPin.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "buttonTapped:"))
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        //Get the windows size infomation
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        //the notification windows to help the user navigate the building
        alertView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 60))
        alertView.backgroundColor = UIColor(red:(244/255.0), green:(179/255.0), blue:(80/255.0), alpha:1.0);
        ok_button = UIButton(frame: CGRect(x:(screenSize.width-70), y: 30, width:50,height:50))
        ok_button.layer.cornerRadius = 0.5 *  ok_button.bounds.size.width
        ok_button.backgroundColor = UIColor.grayColor()
        ok_button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        ok_button.titleLabel?.font = UIFont(name:"Heiti SC", size: 14)
        ok_button.addTarget(self, action: Selector("onClick_ok"), forControlEvents: UIControlEvents.TouchUpInside)
        label = UILabel(frame: CGRect(x:5, y: 30, width:200,height:20))
        label.font = UIFont(name:"Heiti SC", size: 14)
        label.tintColor = UIColor.blackColor()
        self.view.backgroundColor = UIColor.whiteColor()
        self.floorPicker.tableFooterView = UIView(frame: CGRectZero)
        self.getDirections.layer.cornerRadius = 0.5 * self.getDirections.bounds.size.width
        self.helpButton.layer.cornerRadius   = 0.5 * self.getDirections.bounds.size.width
        self.NumberOfFloor = self._building.getNumberOfFloors()
        self.populateFloors()
        self.floorPicker.reloadData()
        self.reDraw(CurrentFloor)
    
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        updateLocation(true)
        self.reDraw(CurrentFloor)
        self.floorPicker.reloadData()
 
    }
    
    
    /* The function that handels dismissing the notification during navigation*/
    func onClick_ok(){
        self.alertView.alpha = 0
        self.ok_button.alpha = 0
         self.label.alpha = 0
        
        UIView.animateWithDuration(1, animations: {
            self.alertView.removeFromSuperview()
            self.ok_button.removeFromSuperview()
            self.label.removeFromSuperview()
        })
        
    }
    
      /* The function that handels asking the user for authorization to use the current location*/
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    
      /* This function focus the camera on the given room if no room is given will default to a bird view of the map */
    
   func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
   // var position = _room.GetroomCenter();
 var position = CLLocationCoordinate2D(latitude: 42.1124531749125, longitude: -86.4693216079577)
    if(CLLocationCoordinate2DIsValid(position)){
        _room.SetIsSelected(true);
        mapView.camera = GMSCameraPosition(target: position, zoom: 17.7, bearing: 0, viewingAngle: 0)
        mapView.mapType = GoogleMaps.kGMSTypeNone
        locationManager.stopUpdatingLocation()
        
    }else{
        position = CLLocationCoordinate2D(latitude: 42.1508511406335, longitude: -86.4427788105087)
        mapView.camera = GMSCameraPosition(target: position, zoom: 17.7,bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
    }

    }
    
    /* After the view has appeared we update the user location*/
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateLocation(true)
    }
    
    
    /* The actual updating of the user location*/
    func updateLocation(running : Bool){
        //Get all the floors in the building
        //self.reDraw(self.CurrentFloor)
    
        let status = CLLocationManager.authorizationStatus()
        if running{
           
                locationManager.startUpdatingLocation()
                self.mapView.myLocationEnabled = true
                self.mapView.settings.myLocationButton = true
        }else{
            locationManager.startUpdatingLocation()
            self.mapView.settings.myLocationButton = false
            self.mapView.myLocationEnabled = false
        }
    }
    
    
    /* In case we failed getting the user location we print an error*/
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        
        reverseGeocodeCoordinate(position.target)
    }
    
    /* Updating the user's address and location as we moved through the building*/
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        // 1
        let geocoder = GMSGeocoder()
        
        // 2
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            
            if(!self.mapPin.hidden){
                for floorClass in self._building.getFloors() {
                   for room in floorClass.getRoomsInFloor(){
                    for rect in room.GetRoomCoordinates(){
                        if(GMSGeometryContainsLocation(coordinate,rect, true)){
                            self.Address.text = room.GetRoomLocation()+" "+room.GetRoomName()
                        }
                    }
                    }
                }
            }else{
                let address = response?.firstResult()
                //let lines = address!.lines as! [String]
                //self.Address.text = lines.joinWithSeparator(", ")

                }
                
                // 4
            
                UIView.animateWithDuration(0.25) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    
    /* Get the number of floors to be displayed*/
    func tableView(floorPicker: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (floors.count)
        
    }
    
    /* Display the the floor picker numbers*/
    func tableView(floorPicker: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = floorPicker.dequeueReusableCellWithIdentifier("cell")
        
        cell!.textLabel!.text = floors[indexPath.row]
        return cell!
        
    }
    /* Function to handel selecting a particular floor*/
    func tableView(floorPicker: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
            floorPicker.deselectRowAtIndexPath(indexPath, animated: true)
            if let myNumber = NSNumberFormatter().numberFromString(floors[indexPath.row]) {
                self.mapView.clear()
                self.reDraw(myNumber.integerValue)
            }
            
        

        
    }
    
    
    /* Drawing the route after clicking on the Icon */
    func buttonTapped(sender: UITapGestureRecognizer) {
        if (sender.state == .Ended) {
            self.drawRoute();
            mapPin.hidden = true;
        }
    }
    
    
/* Function the handels drawing the floor plan of each building*/
    func updateUIMap(floor : Int){
        for floorClass in self._building.getFloors() {
            if(floorClass._floorNumber==floor){
            for room in floorClass.getRoomsInFloor(){
                for rect in room.GetRoomCoordinates(){
                //Label HW and restroom with different colors
                let polygon = GMSPolygon(path: rect)
                if(room.GetIsSelected()){
                    self._room = room
                    let marker = GMSMarker(position: room.GetroomCenter())
                    marker.icon = UIImage(named: "mapannotation.png")
                    marker.flat = true
                    marker.appearAnimation =   GoogleMaps.kGMSMarkerAnimationPop
                    polygon.fillColor = UIColor(red:(137/255.0), green:196/255.0, blue:244/255.0, alpha:1.0);
                    marker.map = self.mapView
                }else{
                    polygon.fillColor = UIColor(red:(255/255.0), green:249/255.0, blue:236/255.0, alpha:1.0);
                }
                if((room.GetRoomName()=="WB") || (room.GetRoomName()=="MB") ){
                    polygon.fillColor = UIColor(red: 234/255.0, green: 230/255.0, blue: 245/255.0, alpha: 1.0)//purple color
                }
                
                if(room.GetRoomName()=="HW"){
                    polygon.fillColor  = UIColor.whiteColor()
                }
                if(room.GetRoomStatus()=="Open"){
                    
                    polygon.fillColor = UIColor(red: 27/255.0, green: 188/255.0, blue: 155/255.0, alpha: 1.0)// open conferance rooms
                }
                if(room.GetRoomStatus()=="Busy"){
                    
                    polygon.fillColor = UIColor(red: 211/255.0, green: 84/255.0, blue:0/255.0, alpha: 1.0)// busy conferance rooms
                }
                
            
                polygon.strokeColor = UIColor(red:(108/255.0), green:(122/255.0), blue:(137/255.0), alpha:1.0);
                polygon.strokeWidth = 0.5
                polygon.title = room.GetRoomName();
                polygon.tappable = true;
                polygon.map = self.mapView
                self.view.setNeedsDisplay()
                    
        
                    
                    
                // Add imge to the bathrooms and Exit/entrance
                if(room.GetRoomName()=="WB"){
                    let icon = UIImage(named: "wbathroom.jpg")
                    let overlay = GMSGroundOverlay(position: room.GetroomCenter(), icon: icon, zoomLevel:20)
                    overlay.bearing = -10
                    overlay.map = self.mapView
                }else if(room.GetRoomName()=="MB"){
                    let icon = UIImage(named: "mbathroom.jpg")
                    let overlay = GMSGroundOverlay(position: room.GetroomCenter(), icon: icon, zoomLevel:20)
                    overlay.bearing = -10
                    overlay.map = self.mapView
                }else if(room.GetRoomName()=="B225"){
                    let icon = UIImage(named: "exit.jpg")
                    let overlay = GMSGroundOverlay(position: room.GetroomCenter(), icon: icon, zoomLevel:20)
                    overlay.bearing = -10
                    overlay.map = self.mapView
                }else if(room.GetRoomName()=="UX"){
                    let icon = UIImage(named: "UX.jpg")
                    let overlay = GMSGroundOverlay(position: room.GetroomCenter(), icon: icon, zoomLevel:20)
                    overlay.bearing = -10
                    overlay.map = self.mapView
                }else if(room.GetRoomType()=="C" || room.GetRoomType()=="H" ){
                    let overlay = GMSGroundOverlay(position: room.GetroomCenter(), icon: newImage(room.GetRoomName(), size: CGSizeMake(12, 12)), zoomLevel:20)
                    overlay.bearing = 0
                    overlay.map = self.mapView
                    
                }

                   

            }
            
        }
        }
        }
        
        
    }

/* Function to detect the user has tapped on a particular room in the floor*/
    func mapView(mapView: GMSMapView!, didTapOverlay overlay: GMSOverlay!) {
        for floorClass in self._building.getFloors() {
                
                for room in floorClass.getRoomsInFloor(){
                    if(room.GetRoomName() == overlay.title){
                        room.SetIsSelected(true);
                    }else{
                        room.SetIsSelected(false);
                    }
                
            }
        }
        self.mapView.clear();
        self.reDraw(self.CurrentFloor);
    }
    
    
    func reDraw(floor : Int){
        dispatch_async(dispatch_get_main_queue()) {
            do {
                self.updateUIMap(floor)

            }
            catch {
                print("Failed to update UI")
            }
        }
        
    }
    
    
    
    
    /* Drawing the navigation path for the user*/
    func drawRoute() {
        
        //self.BannerView("Are you in the 4th floor Yet ?", button_message:"Yes");

        /*let file: NSFileHandle? = NSFileHandle(forReadingAtPath: filepath1)
        
        if file == nil {
            print("File open failed")
        } else {
            file?.seekToFileOffset(10)
            let databuffer = file?.readDataOfLength(5)
            file?.closeFile()
        }
        print(file)*/
    
        
       /* var path1 = GMSMutablePath()
       path1.addCoordinate(CLLocationCoordinate2D(latitude: 42.1124842505816, longitude: -86.4693117141724))
         path1.addCoordinate(CLLocationCoordinate2D(latitude: 42.1124501762335, longitude: -86.4693019911647))
         path1.addCoordinate(CLLocationCoordinate2D(latitude: 42.112486240324, longitude: -86.4691266417503))
         path1.addCoordinate(CLLocationCoordinate2D(latitude: 42.1125648350986, longitude: -86.4691413938999))
         path1.addCoordinate(CLLocationCoordinate2D(latitude: 42.1125710530355, longitude: -86.4691202715039))
        var polyline = GMSPolyline(path: path1)
        polyline.strokeColor = UIColor.blueColor()
        polyline.strokeWidth = 2.0
        polyline.geodesic = true
        polyline.map = mapView;*/
    }
    
    
    /* The banner view for notifying the user and guiding them through floors*/
    func BannerView(label_message : String,button_message : String){
        self.ok_button.setTitle(button_message, forState: UIControlState.Normal)
        self.label.text = label_message
        self.alertView.alpha = 0
        self.ok_button.alpha = 0
        self.label.alpha = 0
        self.view.addSubview(alertView)
        self.view.addSubview(ok_button)
        self.view.addSubview(label)
        UIView.transitionWithView(self.alertView, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            self.alertView.alpha = 1
            self.ok_button.alpha = 1
            self.label.alpha = 1
            }, completion: {
                (value: Bool) in
        })
        
        
    }
    
    
    
    func newImage(text: String, size: CGSize) -> UIImage {
        
        let data = text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        let drawText = NSString(data: data!, encoding: NSUTF8StringEncoding)
        
        let textFontAttributes = [
            NSFontAttributeName: UIFont(name: "Helvetica Bold", size: 4)!,
            NSForegroundColorAttributeName: UIColor.redColor(),
        ]
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        drawText?.drawInRect(CGRectMake(0, 0, size.width, size.height), withAttributes: textFontAttributes)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

    
}