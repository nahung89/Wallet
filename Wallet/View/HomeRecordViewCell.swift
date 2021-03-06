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
    
    let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        formatter.locale = .current
        formatter.minimumFractionDigits = 0
        return formatter
    }()
    
    var record: Record? {
        didSet {
            guard let r = record else { return }
            textLabel?.text = r.title
            detailTextLabel?.text = currencyFormatter.string(from: NSNumber(value: r.cost))
            detailTextLabel?.textColor = r.cost > 0 ? .green : .red
        }
    }
}
