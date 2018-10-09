//
//  HomeController.swift
//  Wallet
//
//  Created by Nah on 10/8/18.
//  Copyright © 2018 Nah. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class HomeViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private var records: Results<Record> = try! Realm().objects(Record.self)
 
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        title = "\(try! Realm().objects(Record.self).sum(ofProperty: "cost") as Double)"
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeRecordViewCell.identifier) as? HomeRecordViewCell
            else { return UITableViewCell() }
        
        cell.record = records[indexPath.row]
        return cell
    }
}
