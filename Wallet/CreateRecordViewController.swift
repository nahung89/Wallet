//
//  CreateRecordViewController.swift
//  Wallet
//
//  Created by Nah on 10/9/18.
//  Copyright © 2018 Nah. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

private enum RecordKind {
    case plus, minus
    var opposite: RecordKind { return self == .plus ? .minus : .plus }
    var text: String { return self == .plus ? "PLUS" : "MINUS" }
    var color: UIColor { return self == .plus ? .green : .red }
    func value(_ value: Double) -> Double { return self == .plus ? value : 0 - value }
}

class CreateRecordViewController: UIViewController {
    
    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var costTextField: UITextField!
    @IBOutlet private var datePicker: UIDatePicker!
    @IBOutlet private var kindButton: UIButton!
    
    private var kind: RecordKind = .plus
    
    private var record: Record = Record()
    
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        formatter.locale = .current
        formatter.minimumFractionDigits = 0
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        kindButtonTouched(kindButton)
    }
    
    func map(record newRecord: Record) {
        self.record = newRecord
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleTextField.text = record.title
        costTextField.text = String(format: "%.0f", record.cost)
        datePicker.date = record.date
        map(kind: record.cost > 0 ? .plus : .minus)
    }
    
    private func map(kind newKind: RecordKind) {
        kind = newKind
        kindButton.setTitle(kind.text, for: .normal)
        kindButton.setTitleColor(kind.color, for: .normal)
        costTextField.textColor = kind.color
    }
}

extension CreateRecordViewController {
    
    @IBAction func kindButtonTouched(_ sender: UIButton) {
        map(kind: kind.opposite)
    }
    
    @IBAction func doneButtonTouched(_ sender: UIButton) {
        let realm = try! Realm()
        try! realm.write {
            record.title = titleTextField.text!
            record.cost = kind.value(abs(Double(costTextField.text!) ?? 0))
            record.date = datePicker.date
            realm.add(record, update: true)
        }
        
        navigationController?.popViewController(animated: true)
    }
}

