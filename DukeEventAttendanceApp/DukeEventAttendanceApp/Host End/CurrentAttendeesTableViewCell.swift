//
//  CurrentAttendeesTableViewCell.swift
//  
//
//  Created by Luiza Wolf on 7/3/19.
//

import UIKit

class CurrentAttendeesTableViewCell: UITableViewCell {

    @IBOutlet weak var dukeCardNumber: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var checkInTime: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
