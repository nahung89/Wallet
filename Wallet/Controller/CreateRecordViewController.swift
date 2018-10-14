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
import RxSwift

class CreateRecordViewController: UIViewController {
    
    @IBOutlet private var viewModel: DetailRecordViewModel!
    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var costTextField: UITextField!
    @IBOutlet private var datePicker: UIDatePicker!
    @IBOutlet private var kindButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.kind.asObservable().subscribe(onNext: { [unowned self] (kind) in
            self.kindButton.setTitle(kind.text, for: .normal)
            self.kindButton.setTitleColor(kind.color, for: .normal)
            self.costTextField.textColor = kind.color
        }).disposed(by: disposeBag)
        
        viewModel.record.asObservable().subscribe(onNext: { [unowned self] (record) in
            self.updateUI(from: record)
        }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel.record.value.title.isEmpty {
            titleTextField.becomeFirstResponder()
        } else if viewModel.record.value.cost == 0 {
            costTextField.becomeFirstResponder()
        }
    }
    
    private func updateUI(from record: Record) {
        titleTextField.text = record.title
        costTextField.text = viewModel.costText(for: record.cost)
        datePicker.date = record.date
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
            let textRange = Range(range, in: text)
            else { return true }
        
        let cursorLocation = textField.position(from: textField.beginningOfDocument, offset: range.location + string.count)
        
        if let text = viewModel.parseNumber(from: text.replacingCharacters(in: textRange, with: string)) {
            textField.text = text
            if let cursor = cursorLocation {
                textField.selectedTextRange = textField.textRange(from: cursor, to: cursor)
            }
            return false
        } else {
            return true
        }
    }
}

extension CreateRecordViewController {
    
    func map(record newRecord: Record) {
        viewModel.record.value = newRecord
        viewModel.kind.value = newRecord.cost > 0 ? .plus : .minus
    }
}

extension CreateRecordViewController {
    
    @IBAction func kindButtonTouched(_ sender: UIButton) {
        viewModel.reverseKind()
    }
    
    @IBAction func doneButtonTouched(_ sender: UIButton) {
        viewModel.update(title: titleTextField.text!, cost: costTextField.text!, date: datePicker.date)
        navigationController?.popViewController(animated: true)
    }
}
