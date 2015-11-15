//
//  NavigationMainViewController.swift
//  Whirlpool-iOS
//
//  Created by Jallal Elhazzat on 9/28/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData
import Foundation

class  BuildingsMapsViewController : UIViewController , CLLocationManagerDelegate,GMSMapViewDelegate,UIPopoverPresentationControllerDelegate, buildingsLoadedDelegate{
    
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
    var _buildins : BuildingsData!
    var _building : Building!
    
    func buildingAbbsHaveBeenLoaded(){

    }
    func buildingInfoHasBeenLoaded(){
        //print( _buildings._buildings["GHQ"]?._floors)
        print("%%%%%%%%%% WE ARE ALL SET %%%%%%%%%%%%%%%%%")
        self._building = self._buildins._buildings[self.CurrentBuilding]
        self.NumberOfFloor = self._building.getNumberOfFloors()
        self.populateFloors()
        self.floorPicker.reloadData()
        self.reDraw(CurrentFloor)
    }
    
    
    @IBAction func pan(sender: UIPanGestureRecognizer) {
        //Get the size of the screen
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        //let screenWidth : CGFloat  = screenSize.width
        let screenHeight : CGFloat  = screenSize.height
        //View will not go out of the frame of the screen
        let MagicNumber : CGFloat = screenSize.height*0.70
        
        //Translate the PX to the screen size
        let translation = sender.translationInView(self.buttomView)
        if let view = sender.view{
            let d: CGFloat = (self.buttomView.center.y + translation.y)
            if(((MagicNumber)<=d)&&(d<(screenHeight+20))){
            self.buttomView.center = CGPoint(x:self.buttomView.center.x,
                y:self.buttomView.center.y + translation.y)
            }
        }
        sender.setTranslation(CGPointZero, inView: self.buttomView)
    
    }
    
    /**
     * Add a prticular room into your favorite rooms
     * upon clicking on a button
     */
    @IBAction func favoriteButton(sender: UIButton) {
        let alert = UIAlertController(title: _room.GetRoomName(), message: "New Favorite Added", preferredStyle: .Alert)
        let attributeString = NSAttributedString(string: "New Favorite", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15),
            NSBackgroundColorDocumentAttribute: UIColor.blueColor()])
        alert.setValue(attributeString, forKey: "attributedMessage")
        //Add to favorite Data Core right here
        self.saveFavoriteRoom(_room)
        presentViewController(alert, animated: true) { () -> Void in
            sleep(1)
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    
    
    @IBAction func book(sender: AnyObject) {
        
        
        
    }
    
    /**
    * All the amenities in a room
    *
    */
    let locationManager = CLLocationManager()
    var RoomAmenities = ["Capacity","Whiteboard","Monitor","Polycom","Phone","TV","Video Conference"]
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var roomLabel: UILabel!
    
    @IBOutlet weak var buttomView: UIView!
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
     self.buttomView.hidden = !self.buttomView.hidden
        
    }
    // The pin that helps locat the user
    @IBOutlet weak var mapPin: UIImageView!
    //Current location for the user
    @IBOutlet weak var Address: UILabel!
    //The map object
    @IBOutlet weak var mapView: GMSMapView!
    
    
    //The number of floors in the given building
    
    func populateFloors(){
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
        /***********************   MAKE SURE YOU UPDATE THIS VARIABLES******************************/
        self.CurrentFloor = 1 // Make sure you fix this later on
        self.CurrentBuilding = "GHQ"
        self._buildins = BuildingsData(delegate: self, buildingAbb: self.CurrentBuilding)
        /*******************************************************************************************/
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

    
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
     
        //updateLocation(true)
        //self.reDraw(CurrentFloor)
        self.floorPicker.reloadData()
        if _room.GetRoomName() != "" {
            self.roomLabel.text = _room.GetRoomName()
        }
 
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
     var position = CLLocationCoordinate2D(latitude: 42.1508511406335, longitude: -86.4427788105087)
    if(CLLocationCoordinate2DIsValid(position)){
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
        if _room.GetRoomName() != "" {
            roomLabel.text = _room.GetRoomName()
        }
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
                            
                            var lines = ["Building : \(self.CurrentBuilding)","Floor : \(self.CurrentFloor)"," Room : \(room.GetRoomName())"]
                            self.Address.text = lines.joinWithSeparator(", ")
                            
                            
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
        
        if(floorPicker == self.floorPicker){
            
            return floors.count
            
        }else{
            return RoomAmenities.count
            
        }
        
    }
    
    /* Display the floor picker and and the room details in the each tableView*/
    func tableView(tableViews: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if(tableViews == self.floorPicker){
            print(floors[indexPath.row])
            cell!.textLabel!.text = floors[indexPath.row]
            return cell!
            
        }else{
            let items = _room.GetRoomResources()
            cell!.textLabel!.text = RoomAmenities[indexPath.row]
            if(cell!.textLabel!.text=="Capacity"){
                cell!.detailTextLabel!.text = "\(_room.GetRoomCapacity())"
                
            }else if(cell!.textLabel!.text=="Whiteboard"){
                if(items.contains("White Board")){
                    
                    cell!.detailTextLabel!.text = "Yes"
                }else{
                    cell!.detailTextLabel!.text = "No"
                }
            }else if(cell!.textLabel!.text=="Monitor"){
                if(items.contains("Monitor")){
                    
                    cell!.detailTextLabel!.text = "Yes"
                }else{
                    cell!.detailTextLabel!.text = "No"
                }
            }else if(cell!.textLabel!.text=="Polycom"){
                if(items.contains("Polycom")){
                    
                    cell!.detailTextLabel!.text = "Yes"
                }else{
                    cell!.detailTextLabel!.text = "No"
                }
            }else if(cell!.textLabel!.text=="Phone"){
                if(items.contains("Telephone")){
                    
                    cell!.detailTextLabel!.text = "Yes"
                }else{
                    cell!.detailTextLabel!.text = "No"
                }
                
            }else if(cell!.textLabel!.text=="TV"){
                if(items.contains("TV")){
                    
                    cell!.detailTextLabel!.text = "Yes"
                }else{
                    cell!.detailTextLabel!.text = "No"
                }
            }
            
            return cell!
            
        }
    }

    /* Function to handel selecting a particular floor*/
    func tableView(floorPicker: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if(floorPicker==self.floorPicker){
            
            floorPicker.deselectRowAtIndexPath(indexPath, animated: true)
            if let myNumber = NSNumberFormatter().numberFromString(floors[indexPath.row]) {
                self.mapView.clear()
                self.CurrentFloor = myNumber.integerValue
                self.reDraw(self.CurrentFloor)
            }
            
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
                    self.roomLabel.text = room.GetRoomName()
                    self.tableView.reloadData()
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
                }else if(room.GetRoomName()=="EXT"){
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
      self.view.setNeedsDisplay()
        
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
        
        self.BannerView("Elevator and Stairs are to your left", button_message:"Yes");

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
            NSForegroundColorAttributeName: UIColor.blackColor(),
        ]
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        drawText?.drawInRect(CGRectMake(0, 0, size.width, size.height), withAttributes: textFontAttributes)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "bookRoomSeg" {
            let eventVC = segue.destinationViewController as! CalendarEventViewController
            eventVC.guest = _room.GetRoomEmail()
            eventVC.location = _room.GetRoomName()
            
        }
        
    }
    
    func saveFavoriteRoom(room: RoomData){
        let appDelagate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelagate.managedObjectContext
        
        
        let entity = NSEntityDescription.entityForName("Favorites", inManagedObjectContext: managedContext)
        
        let favoriteRoom = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        favoriteRoom.setValue(room.GetRoomName(), forKey: "roomName")
        favoriteRoom.setValue(room.GetRoomEmail(), forKey: "roomEmail")
        
        //4
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }

    
}