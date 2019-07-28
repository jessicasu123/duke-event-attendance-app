//
//  HostTableViewCell.swift
//  DukeEventAttendanceApp
//
//  Created by Luiza Wolf on 7/3/19.
//  Copyright © 2019 Duke OIT. All rights reserved.
//

import UIKit

protocol HostTableViewCellDelegate {
    func didTapAllowCheckIn(eventid:String)
}

class HostTableViewCell: UITableViewCell {
    
    var event: Event!
    var delegate: HostTableViewCellDelegate?
    
    @IBOutlet weak var eventTitle: UILabel!
    
    @IBOutlet weak var backgroundCard: UIView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var allowCheckInButton: UIButton!
    @IBOutlet weak var locLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var active = false 
    
    @IBAction func allowCheckInTapped(_ sender: Any) {
        print(event)
        delegate?.didTapAllowCheckIn(eventid: event.id) //call didTapAllowCheckIn from HostTableViewController
    }
    
    //Called by HostTableViewController to store event of current row
    func setEvent(event: Event){
        print("eventset")
        self.event = event
        if( self.active ){
            self.allowCheckInButton.setTitle("A C T I V E", for: .normal)
            self.allowCheckInButton.titleLabel?.centerXAnchor.constraint(equalTo: self.allowCheckInButton.centerXAnchor).isActive = true
            self.allowCheckInButton.titleLabel?.centerYAnchor.constraint(equalTo: self.allowCheckInButton.centerYAnchor).isActive = true
            self.allowCheckInButton.backgroundColor = UIColor.white
//            self.allowCheckInButton.titleLabel?.text = "A C T I V E"
        } else {
            self.allowCheckInButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.76)
            self.allowCheckInButton.setTitle("A L L O W  C H E C K - I N", for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
