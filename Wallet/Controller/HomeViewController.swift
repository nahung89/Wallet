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
import DateHelper

class HomeViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private var realm: Realm!
    private var groupedItems: [Date: Results<Record>] = Dictionary()
    private var itemDates: [Date] = Array()
    private let currencyFormatter = NumberFormatter()
    private let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realm = MyRealm.main
        
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = .current
        currencyFormatter.minimumFractionDigits = 0
        
        dateFormatter.dateStyle = .medium
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
        tableView.reloadData()
    }
    
    @IBAction func createButtonTouched(_ sender: UIButton) {
        openDetail(Record())
    }
    
    @IBAction func exportButtonTouched(_ sender: UIButton) {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .short
        
        let cacheUrl = FileManager().urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: .userDomainMask).first!
        let fileUrl = cacheUrl.appendingPathComponent("\(Date()).csv")
        
        var csvText = "Title,Cost,Date\n"
        
        for date in itemDates {
            for record in groupedItems[date]! {
                let newLine = "\(record.title),\(record.cost), \(timeFormatter.string(from: record.date))"
                csvText.append(newLine)
            }
        }
        
        print(fileUrl)
        
        do {
            try csvText.write(to: fileUrl, atomically: true, encoding: .utf8)
            openShare([fileUrl])
        } catch {
            print("Failed to create file: \(error)")
        }
    }
}

private extension HomeViewController {
    
    private func openDetail(_ record: Record) {
        // swiftlint:disable:next force_cast
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateRecordViewController") as! CreateRecordViewController
        controller.map(record: record)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func openShare(_ items: [Any]) {
        let shareController = UIActivityViewController.init(activityItems: items, applicationActivities: nil)
        navigationController?.present(shareController, animated: true)
    }
    
    private func reloadData() {
        let total: Double = realm.objects(Record.self).sum(ofProperty: "cost")
        title  = currencyFormatter.string(from: NSNumber(value: total))
        
        let records = realm.objects(Record.self)
        
        itemDates = records.reduce(into: [Date](), { (results, record) in
            let date = record.date.dateFor(.startOfDay)
            if !results.contains(date) { results.append(date) }
        }).sorted(by: { $0 > $1 })
        
        groupedItems = itemDates.reduce(into: [Date: Results<Record>](), { (results, date) in
            results[date] = realm.objects(Record.self).filter("date >= %@ AND date <= %@", date.dateFor(.startOfDay), date.dateFor(.endOfDay)).sorted(byKeyPath: "date", ascending: false)
        })
//        
//        //Filter each Item in realm based on their date property and assign the results to the dictionary
//        groupedItems = itemDates.reduce(into: [Date:Results<Record>](), { results, date in
//            let beginningOfDay = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: Calendar.current.component(.day, from: date), hour: 0, minute: 0, second: 0))!
//            let endOfDay = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: Calendar.current.component(.day, from: date), hour: 23, minute: 59, second: 59))!
//            results[beginningOfDay] = realm.objects(Record.self).filter("date >= %@ AND date <= %@", beginningOfDay, endOfDay).sorted(byKeyPath: "date", ascending: false)
//        })
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemDates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedItems[itemDates[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = dateFormatter.string(from: itemDates[section])
        let totalDate: Double = groupedItems[itemDates[section]]!.sum(ofProperty: "cost")
        return "\(date): \(currencyFormatter.string(from: NSNumber(value: totalDate))!)"
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeRecordViewCell.identifier) as? HomeRecordViewCell else {
            return UITableViewCell()
        }
        let group = groupedItems[itemDates[indexPath.section]]
        cell.record = group?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let record = groupedItems[itemDates[indexPath.section]]?[indexPath.row] else { return }
        openDetail(record)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [unowned self] (_, indexPath) in
            guard let record = self.groupedItems[self.itemDates[indexPath.section]]?[indexPath.row] else { return }
            
            let countSection = self.itemDates.count
            
            try? self.realm.write {
                self.realm.delete(record)
            }
            
            self.reloadData()
            
            if countSection != self.itemDates.count {
                self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            } else {
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
        return [delete]
    }
}
