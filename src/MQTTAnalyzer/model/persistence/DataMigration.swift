//
//  DataMigration.swift
//  MQTTAnalyzer
//
//  Created by Philipp Arndt on 2020-01-19.
//  Copyright © 2020 Philipp Arndt. All rights reserved.
//

import Foundation
import RealmSwift

class DataMigration {
	class func initMigration() {
		let configuration = Realm.Configuration(
			schemaVersion: 6,
			migrationBlock: { migration, oldSchemaVersion in
				if oldSchemaVersion < 4 {
					migration.enumerateObjects(ofType: HostSetting.className()) { _, newObject in
						newObject!["limitTopic"] = 250
						newObject!["limitMessagesBatch"] = 1000
					}
				}
				
				// Add support for different auth types
				if oldSchemaVersion < 5 {
					migration.enumerateObjects(ofType: HostSetting.className()) { oldObject, newObject in
						let auth = oldObject!["auth"] as! Bool
						if auth {
							newObject!["authType"] = AuthenticationType.USERNAME_PASSWORD
						}
						else {
							newObject!["authType"] = AuthenticationType.NONE
						}
					}
				}

//				Example on how to rename properties:
//				if oldSchemaVersion < n {
//					migration.renameProperty(onType: HostSetting.className(), from: "old", to: "new")
//				}
				
//				Example on how to delete old properties:
//				if oldSchemaVersion < n {
//					// nothing to do (realm will add new properties and delete old)
//				}
			}
		)
		Realm.Configuration.defaultConfiguration = configuration
	}
}
