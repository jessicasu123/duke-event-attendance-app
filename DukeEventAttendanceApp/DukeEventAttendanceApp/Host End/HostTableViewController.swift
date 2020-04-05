//
//  HostTableViewController.swift
//  DukeEventAttendanceApp
//
//  Created by Luiza Wolf on 7/2/19.
//  Copyright © 2019 Duke OIT. All rights reserved.
//
import UIKit
import Apollo
import CoreLocation


class HostTableViewController: UITableViewController, HostTableViewCellDelegate, CLLocationManagerDelegate {

    
    var host_events = [String]()
    var actual_events = [Event]()
    var months = [String]()
    var month_events = [String: [Event]]()
    
    var activeEvents = [String]()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        let hnc = self.storyboard?.instantiateViewController(withIdentifier: "hostNav") as? UINavigationController
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
        
        getActiveEvents(nav: self.navigationController!) {activeEvents, error in
            self.activeEvents = activeEvents
            print("MY ACTIVE EVENTS ARE")
            print(activeEvents)
            
            self.host_events.removeAll()
            self.actual_events.removeAll()
            self.months.removeAll()
            self.month_events.removeAll()
            self.getQuery(nav: hnc!) { hostEvents, error in
                self.host_events = hostEvents
                for event in self.host_events {
                    let ev = Items.sharedInstance.eventArray.first(where: { $0.id == event})
                    if (ev != nil) {
                        self.actual_events.append(ev!)
                        if( !self.months.contains( ev!.longmonth )){
                            self.months.append(ev!.longmonth)
                            self.month_events[ev!.longmonth] = [Event]()
                        }
                        self.month_events[ev!.longmonth]?.append(ev!)
                    }
                    
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM"
                self.months = self.months.sorted(by: { dateFormatter.date(from:$0)!.compare(dateFormatter.date(from:$1)!) == .orderedAscending })
                print (self.months)
                
                
                
                for (month,events) in self.month_events {
                    //var events = self.month_events[month]
                    if (events.count > 0) {
                        self.month_events[month] = events.sorted(by: { $0.sorted_date.compare($1.sorted_date) == .orderedAscending})
                        for event in events {
                            print (event.summary)
                        }
                    }
                    
                }
                
                
                self.actual_events = self.actual_events.sorted(by: { $0.sorted_date.compare($1.sorted_date) == .orderedAscending} )
               
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        // Register the custom header view.
        tableView.register(MonthCustomHeader.self,
                           forHeaderFooterViewReuseIdentifier: "MonthCustomHeader")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.months.count
    }
    
    func getQuery(nav: UINavigationController, completionHandler: @escaping (_ hostEvents: [String], _ error: String?) -> Void){
        
        let query = HostsEventsQuery()
        Apollo().getClient().fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { [unowned self] results, error in
            print(results)
            if let error = error as? GraphQLHTTPResponseError {
                switch (error.response.statusCode) {
                    case 401:
                        //request unauthorized due to bad token
                        
                        OAuthService.shared.refreshToken(navController: nav) { success, statusCode in
                            if success {
                        
                                self.getQuery(nav: nav) { hostEvents, error in
                                    completionHandler(hostEvents, error)
                                }
                            } else {
                                //handle error
                            }
                            
                        }
                    default:
                        print (error.localizedDescription)
                }
            }
            else if let hostevents = results?.data?.hostEvents{
                for event in hostevents {
                    
                    self.host_events.append( event.resultMap["eventid"]!! as! String )
                    
                    //self.tableView.reloadData()
                }

                DispatchQueue.main.async {
                    completionHandler(self.host_events, nil)
                }
                
                
                
            } else{
                let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                let messageLabel = UILabel(frame: rect)
                messageLabel.text = "You are not hosting any events"
                messageLabel.textColor = UIColor.black
                messageLabel.textAlignment = .center;
                messageLabel.font = UIFont(name: "Helvetica-Light", size: 22)
                messageLabel.sizeToFit()
                self.tableView.backgroundView = messageLabel
            }
        }
    }
    
    func getActiveEvents(nav: UINavigationController, completionHandler: @escaping (_ activeEvents: [String], _ error: String?) -> Void){
        
        let query = GetActiveEventsQuery()
        Apollo().getClient().fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { [unowned self] results, error in
            
            if let error = error as? GraphQLHTTPResponseError {
                switch (error.response.statusCode) {
                case 401:
                    //request unauthorized due to bad token
                    
                    OAuthService.shared.refreshToken(navController: nav) { success, statusCode in
                        if success {
                            
                            self.getActiveEvents(nav: nav) { activeEvents, error in
                                completionHandler(activeEvents, error)
                            }
                        } else {
                            //handle error
                        }
                        
                    }
                default:
                    print (error.localizedDescription)
                }
            }
            else if let activeEvents = results?.data?.getActiveEvents{
                for event in activeEvents {
                    
                    self.activeEvents.append( event.resultMap["eventid"]!! as! String )
                }
                
                DispatchQueue.main.async {
                    completionHandler(self.activeEvents, nil)
                }
                
                
                
            } else{
                
            }
        }
    }
    
    //Delegate method
    func didTapAllowCheckIn(eventid:String) {
        let alert = UIAlertController(title: "Choose Check-In Method", message: "Please choose method by which attendees will check in to your event", preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "QR Code", style: .default, handler: {(action) -> Void in
            let qvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QRCodeViewController") as? QRCodeViewController
            qvc?.event_id = eventid
            Items.sharedInstance.openEvent(eventid: eventid, checkintype: "qr", nav: self.navigationController!)
            self.navigationController?.show(qvc!, sender: true)
        } ) )
        alert.addAction( UIAlertAction(title: "Self Check-In (Event) ", style: .default, handler: {(action) -> Void in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CurrentAttendees") as? CurrentAttendeesTableViewController
            vc?.event_id = eventid
            Items.sharedInstance.openEvent(eventid: eventid, checkintype: "self", nav: self.navigationController!)
            self.navigationController?.pushViewController(vc!, animated: true)
        } ) )
        
        alert.addAction( UIAlertAction(title: "Self Check-In (Host) ", style: .default, handler: {(action) -> Void in
                       let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CurrentAttendees") as? CurrentAttendeesTableViewController
            vc?.event_id = eventid
            
            Items.sharedInstance.openEvent(eventid: eventid, checkintype: "self_host_loc", nav: self.navigationController!)
            self.navigationController?.pushViewController(vc!, animated: true)
        } ) )
        
        if (self.activeEvents.contains(eventid)) {
            alert.addAction( UIAlertAction(title: "Close Event", style: .default, handler: {(action) -> Void in
                Items.sharedInstance.closeEvent(eventid: eventid, nav: self.navigationController!)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } ) )
        }
        
        alert.addAction( UIAlertAction(title: "Cancel", style: .cancel, handler: nil) )
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
//    // Create a standard header that includes the returned text.
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection
//        section: Int) -> String? {
//
//        return "Header \(section)"
//    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier:
            "MonthCustomHeader") as! MonthCustomHeader
        //view.customLabel.text = self.months[section]
        view.customLabel.attributedText = NSAttributedString(string: self.months[section].uppercased(), attributes: [NSAttributedString.Key.kern: 5.0, NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 18)!, NSAttributedString.Key.foregroundColor: UIColor(red:0.00, green:0.13, blue:0.41, alpha:1.0)])
        return view
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.month_events[months[section]]!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "please", for: indexPath) as? HostTableViewCell else{
            fatalError("the cell is not an instance of the table view cell")
        }
        // Configure the cell...
        
        let event = self.month_events[months[indexPath.section]]![indexPath.row]
        if event != nil{
            cell.eventTitle.text = event.summary
            cell.monthLabel.text = event.startmonth.uppercased()
            cell.dayLabel.text = event.startday
            cell.timeLabel.text = "Time: " + event.starttime + " - " + event.endtime
            cell.locLabel.text = "Location: " + event.address
        }
        cell.backgroundCard.layer.cornerRadius = 10.0
        cell.allowCheckInButton.layer.cornerRadius = 10.0
        
        cell.delegate = self
        if (self.activeEvents.contains(event.id)) {
            cell.active = true
        }
        
        if (!self.activeEvents.contains(event.id)) {
            cell.active = false
            
        }
        cell.delegate = self
        cell.setEvent(event: event ?? Event.init(id: "", start_date: "", end_date: "", summary: "", description: "", status: "", sponsor: "", co_sponsors: "", location: ["":""], contact: ["":""], categories: [""], link: "", event_url: "", series_name: "", image_url: "")!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //eventually include guard to not track location unless HOST
        
        let userLocation :CLLocation = locations[0] as CLLocation
        print(userLocation.coordinate)
       
        Items.sharedInstance.hostLocLat = "\(userLocation.coordinate.latitude)"
        Items.sharedInstance.hostLocLong = "\(userLocation.coordinate.latitude)"
        print(Items.sharedInstance.hostLocLat)
        
       
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
