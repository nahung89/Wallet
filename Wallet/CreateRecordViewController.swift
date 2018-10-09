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
    
    @IBOutlet private var titleTextView: UITextView!
    @IBOutlet private var costTextField: UITextField!
    @IBOutlet private var datePicker: UIDatePicker!
    @IBOutlet private var kindButton: UIButton!
    
    private var kind: RecordKind = .minus
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [costTextField, titleTextView].forEach { itemView in
            itemView?.layer.borderWidth = 1
            itemView?.layer.borderColor = UIColor.black.cgColor
        }
        kindButtonTouched(kindButton)
    }
}

extension CreateRecordViewController {
    
    @IBAction func kindButtonTouched(_ sender: UIButton) {
        kind = kind.opposite
        kindButton.setTitle(kind.text, for: .normal)
        kindButton.setTitleColor(kind.color, for: .normal)
    }
    
    @IBAction func doneButtonTouched(_ sender: UIButton) {
        let record = Record()
        record.title = titleTextView.text
        record.cost = kind.value(Double(costTextField.text!) ?? 0)
        record.date = datePicker.date
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(record)
        }
        
        navigationController?.popViewController(animated: true)
    }
}

