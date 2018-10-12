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
    var text: String { return self == .plus ? "ADD" : "REMOVE" }
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
    
    private let numberFormatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        kindButtonTouched(kindButton)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale.current
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.usesGroupingSeparator = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleTextField.text = record.title
        costTextField.text = numberFormatter.string(from: NSNumber(value: abs(record.cost)))
        datePicker.date = record.date
        map(kind: record.cost > 0 ? .plus : .minus)
        
        if record.title.isEmpty {
            titleTextField.becomeFirstResponder()
        } else if record.cost == 0 {
            costTextField.becomeFirstResponder()
        }
    }
}

extension CreateRecordViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if costTextField.text == "0" {
            costTextField.text = ""
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard
            let text = textField.text,
            let textRange = Range(range, in: text),
            let separator = numberFormatter.groupingSeparator
            else { return true }
        
        let cursorLocation = textField.position(from: textField.beginningOfDocument, offset: range.location + string.count)
        
        let finalText = text.replacingCharacters(in: textRange, with: string).replacingOccurrences(of: separator, with: "")
        
        if let number = numberFormatter.number(from: finalText) {
            textField.text = numberFormatter.string(from: number)
            
            if let cursor = cursorLocation {
                textField.selectedTextRange = textField.textRange(from: cursor, to: cursor)
            }
            
            return false
        }
        
        return true
    }
}

extension CreateRecordViewController {
    
    func map(record newRecord: Record) {
        self.record = newRecord
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
        let costValue: String = costTextField.text!.replacingOccurrences(of: numberFormatter.groupingSeparator, with: "")
        
        let realm = try! Realm()
        try! realm.write {
            record.title = titleTextField.text!
            record.cost = kind.value(abs(Double(costValue) ?? 0))
            record.date = datePicker.date
            realm.add(record, update: true)
        }
        
        navigationController?.popViewController(animated: true)
    }
}


