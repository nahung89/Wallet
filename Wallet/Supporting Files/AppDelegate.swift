//
//  AppDelegate.swift
//  Wallet
//
//  Created by Nah on 10/8/18.
//  Copyright © 2018 Nah. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // The enumerateObjects(ofType:_:) method iterates
                    // over every Person object stored in the Realm file
                    migration.enumerateObjects(ofType: Record.className()) { _, newObject in
                        newObject!["id"] = UUID().uuidString
                    }
                }
        })
        
//        // Inside your application(application:didFinishLaunchingWithOptions:)
//        let config = Realm.Configuration(
//            // Set the new schema version. This must be greater than the previously used
//            // version (if you've never set a schema version before, the version is 0).
//            schemaVersion: 1,
//
//            // Set the block which will be called automatically when opening a Realm with
//            // a schema version lower than the one set above
//            migrationBlock: { migration, oldSchemaVersion in
//                // We haven’t migrated anything yet, so oldSchemaVersion == 0
//                if (oldSchemaVersion < 1) {
//                    migration.enumerate(Inventory.className()) { oldObject, newObject in
//                        // No-op.
//                        // dynamic properties are defaulting the new column to true
//                        // but the migration block is still needed
//                    }
//                    migration.enumerate(Profile.className()) { oldObject, newObject in
//                        // No-op.
//                        // dynamic properties are defaulting the new column to true
//                        // but the migration block is still needed
//                    }
//                    migration.enumerate(Room.className()) { oldObject, newObject in
//                        // No-op.
//                        // dynamic properties are defaulting the new column to true
//                        // but the migration block is still needed
//                    }
//                    migration.enumerate(Box.className()) { oldObject, newObject in
//                        // No-op.
//                        // dynamic properties are defaulting the new column to true
//                        // but the migration block is still needed
//                    }
//                }
//        })
//
//        // Tell Realm to use this new configuration object for the default Realm
//        Realm.Configuration.defaultConfiguration = config
//
//        // Now that we've told Realm how to handle the schema change, opening the file
//        // will automatically perform the migration
//        do {
//            _ = try Realm()
//        } catch let _ as NSError {
//            // print error
//        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}
