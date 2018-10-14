//
//  HomeViewModel.swift
//  Wallet
//
//  Created by Nah on 10/14/18.
//  Copyright © 2018 Nah. All rights reserved.
//

import Foundation
import RealmSwift

enum RemoveState {
    case none, row, section
}

class HomeViewModel: NSObject {
    
    private(set) var title: String?
    private(set) var groupedItems: [Date: Results<Record>] = Dictionary()
    private(set) var itemDates: [Date] = Array()
    
    private lazy var realm: Realm = MyRealm.main
    
    private let currencyFormatter = NumberFormatter()
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = .current
        currencyFormatter.minimumFractionDigits = 0
        
        dateFormatter.dateStyle = .medium
    }
    
    func reloadData() {
        let records = realm.objects(Record.self)
        
        let sum: Double = records.sum(ofProperty: "cost")
        title = currencyFormatter.string(from: NSNumber(value: sum))
        
        itemDates = records.reduce(into: [Date](), { (results, record) in
            let date = record.date.dateFor(.startOfDay)
            if !results.contains(date) { results.append(date) }
        }).sorted(by: { $0 > $1 })
        
        groupedItems = itemDates.reduce(into: [Date: Results<Record>](), { (results, date) in
            results[date] = realm.objects(Record.self).filter("date >= %@ AND date <= %@", date.dateFor(.startOfDay), date.dateFor(.endOfDay)).sorted(byKeyPath: "date", ascending: false)
        })
    }
    
    func exportData() -> URL? {
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
            return fileUrl
        } catch {
            print("Failed to create file: \(error)")
            return nil
        }
    }
    
    func delete(record: Record) -> RemoveState {
        let countSection = itemDates.count
        
        do {
            try realm.write {
                realm.delete(record)
            }
        } catch {
            return .none
        }
        
        reloadData()
        
        return countSection != itemDates.count ? .section : .row
    }
    
    func title(for section: Int) -> String {
        let date = dateFormatter.string(from: itemDates[section])
        let totalDate: Double = groupedItems[itemDates[section]]!.sum(ofProperty: "cost")
        return "\(date): \(currencyFormatter.string(from: NSNumber(value: totalDate))!)"
    }
    
    func item(at section: Int, row: Int) -> Record? {
        return groupedItems[itemDates[section]]?[row]
    }
    
    func numberOfItem(at section: Int) -> Int {
        return groupedItems[itemDates[section]]?.count ?? 0
    }
}
