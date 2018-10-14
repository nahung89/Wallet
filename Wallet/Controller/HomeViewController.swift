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
    @IBOutlet private var viewModel: HomeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    @IBAction func createButtonTouched(_ sender: UIButton) {
        openDetail(Record())
    }
    
    @IBAction func exportButtonTouched(_ sender: UIButton) {
        guard let url = viewModel.exportData() else { return }
        openShare([url])
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
        viewModel.reloadData()
        tableView.reloadData()
        title  = viewModel.title
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.itemDates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItem(at: section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.title(for: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeRecordViewCell.identifier) as? HomeRecordViewCell else {
            return UITableViewCell()
        }
        cell.record = viewModel.item(at: indexPath.section, row: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let record = viewModel.item(at: indexPath.section, row: indexPath.row) else { return }
        openDetail(record)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [unowned self] (_, indexPath) in
            
            guard let record = self.viewModel.item(at: indexPath.section, row: indexPath.row) else { return }
            switch self.viewModel.delete(record: record) {
            case .row:
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            case .section:
                self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            default: break
            }
            self.title = self.viewModel.title
        }
        return [delete]
    }
}
