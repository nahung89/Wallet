//
//  HomeRecordViewCell.swift
//  Wallet
//
//  Created by Nah on 10/9/18.
//  Copyright © 2018 Nah. All rights reserved.
//

import Foundation
import UIKit

class HomeRecordViewCell: UITableViewCell {
    
    static let identifier: String = "HomeRecordViewCell"
    
    var record: Record? {
        didSet {
            guard let r = record else { return }
            textLabel?.text = r.title
            detailTextLabel?.text = "\(r.cost)"
            detailTextLabel?.textColor = r.cost > 0 ? .green : .red
        }
    }
}
