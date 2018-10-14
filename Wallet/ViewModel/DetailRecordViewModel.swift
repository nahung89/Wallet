//
//  DetailRecordViewModel.swift
//  Wallet
//
//  Created by Nah on 10/14/18.
//  Copyright © 2018 Nah. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import RxSwift

enum RecordKind {
    case plus, minus
    var text: String { return self == .plus ? "ADD" : "REMOVE" }
    var color: UIColor { return self == .plus ? .green : .red }
}

class DetailRecordViewModel: NSObject {
    
    private lazy var realm: Realm = MyRealm.main
    
    let kind: Variable<RecordKind> = Variable(.minus)
    let record: Variable<Record> = Variable(Record())
    
    private let numberFormatter = NumberFormatter()
    
    override init() {
        super.init()
        
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale.current
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.usesGroupingSeparator = true
    }
    
    func update(title: String, cost: String, date: Date) {
        guard let costValue = numberFormatter.number(from: cost)?.doubleValue else { return }
        let recordValue = record.value
        
        try? realm.write {
            recordValue.title = title
            recordValue.cost = kind.value == .plus ? abs(costValue) : 0 - abs(costValue)
            recordValue.date = date
            realm.add(recordValue, update: true)
        }
    }
    
    func costNumber(for costText: String) -> Double {
        let realText = costText.replacingOccurrences(of: numberFormatter.groupingSeparator, with: "")
        guard let value = numberFormatter.number(from: realText)?.doubleValue else { return 0 }
        return kind.value == .plus ? abs(value) : 0 - abs(value)
    }
    
    func costText(for costNumber: Double) -> String {
        return numberFormatter.string(from: NSNumber(value: abs(costNumber))) ?? ""
    }
    
    func parseNumber(from text: String) -> String? {
        let realText = text.replacingOccurrences(of: numberFormatter.groupingSeparator, with: "")
        guard let number = numberFormatter.number(from: realText) else { return nil }
        return numberFormatter.string(from: number)
    }
    
    func reverseKind() {
        kind.value = kind.value == .plus ? .minus : .plus
    }
}
