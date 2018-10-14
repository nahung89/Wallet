//
//  MyRealm.swift
//  Wallet
//
//  Created by Nah on 10/12/18.
//  Copyright © 2018 Nah. All rights reserved.
//

import Foundation
import RealmSwift

class MyRealm {
    // swiftlint:disable:next force_try
    public static let main: Realm = try! Realm()
}
