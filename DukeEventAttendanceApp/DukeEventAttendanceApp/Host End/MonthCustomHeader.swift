//
//  MonthCustomHeader.swift
//  DukeEventAttendanceApp
//
//  Created by Luiza Wolf on 7/19/19.
//  Copyright © 2019 Duke OIT. All rights reserved.
//

import UIKit

/*
    This class is responsible for creating a custom header for the month.
    For both attendees and hosts, their table views will have a month header,
    followed by a group of table view cells for events that take place during
    that month. 
 */
class MonthCustomHeader: UITableViewHeaderFooterView {

    static let reuseIdentifer = "MonthCustomHeader"
    let customLabel = UILabel.init()
    
    override public init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        customLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.backgroundColor = UIColor.white
        self.contentView.heightAnchor.constraint(equalToConstant: 35.0).isActive = true
        self.contentView.addSubview(customLabel)
        customLabel.heightAnchor.constraint(equalToConstant: 35.0).isActive = true
        
        let margins = contentView.layoutMarginsGuide
        customLabel.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        customLabel.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
