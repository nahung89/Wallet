//
//  Record.swift
//  Wallet
//
//  Created by Nah on 10/9/18.
//  Copyright © 2018 Nah. All rights reserved.
//

import Foundation
import RealmSwift

class Record: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var cost: Double = 0
    @objc dynamic var date: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }

}
