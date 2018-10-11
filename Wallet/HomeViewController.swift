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
    
    private var realm: Realm!
//    private var records: Results<Record> = Results()
    var groupedItems: [Date: Results<Record>] = Dictionary()
    var itemDates: [Date] = Array()
    
    let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        formatter.locale = .current
        formatter.minimumFractionDigits = 0
        return formatter
    }()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
        tableView.reloadData()
    }
    
    private func reloadData() {
//        let realm = try! Realm()
        
        let total: Double = realm.objects(Record.self).sum(ofProperty: "cost")
        title  = currencyFormatter.string(from: NSNumber(value: total))
        
        let records = realm.objects(Record.self)
        
        itemDates = records.reduce(into: [Date](), { (results, currentItem) in
            let date = currentItem.date
            let beginningOfDay = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: Calendar.current.component(.day, from: date), hour: 0, minute: 0, second: 0))!
            let endOfDay = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: Calendar.current.component(.day, from: date), hour: 23, minute: 59, second: 59))!
            //Only add the date if it doesn't exist in the array yet
            if !results.contains(where: { addedDate -> Bool in
                return addedDate >= beginningOfDay && addedDate <= endOfDay
            }) {
                results.append(beginningOfDay)
            }
        })
        
        //Filter each Item in realm based on their date property and assign the results to the dictionary
        groupedItems = itemDates.reduce(into: [Date:Results<Record>](), { results, date in
            let beginningOfDay = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: Calendar.current.component(.day, from: date), hour: 0, minute: 0, second: 0))!
            let endOfDay = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: Calendar.current.component(.day, from: date), hour: 23, minute: 59, second: 59))!
            results[beginningOfDay] = realm.objects(Record.self).filter("date >= %@ AND date <= %@", beginningOfDay, endOfDay).sorted(byKeyPath: "date", ascending: false)
        })
    }
    
    @IBAction func createButtonTouched(_ sender: UIButton) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateRecordViewController") as! CreateRecordViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("D: \(itemDates.count)")
        return itemDates.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("E: \(groupedItems[itemDates[section]]!.count)")
        return groupedItems[itemDates[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: itemDates[section])
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeRecordViewCell.identifier) as? HomeRecordViewCell
            else { return UITableViewCell() }
        
        let group = groupedItems[itemDates[indexPath.section]]
        cell.record = group?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let record = groupedItems[itemDates[indexPath.section]]?[indexPath.row] else { return }
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateRecordViewController") as! CreateRecordViewController
        controller.map(record: record)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [unowned self] (action, indexPath) in
            guard let record = self.groupedItems[self.itemDates[indexPath.section]]?[indexPath.row] else { return }
            
            print("1A \(self.itemDates)")
            print("1B \(self.groupedItems.map({ $0.value.count }))")
            
            let countSection = self.itemDates.count
            
//            let realm = try! Realm()
            try! self.realm.write {
                self.realm.delete(record)
            }
            
            self.reloadData()
            
            print("2A \(self.itemDates)")
            print("2B \(self.groupedItems.map({ $0.value.count }))")
            print("delete: \(indexPath.section) -- \(indexPath.row)")
            
            if countSection != self.itemDates.count {
                self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            } else {
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
        return [delete]
    }
}
