//
//  Database.swift
//  RSSchoolHackatonApp
//
//  Created by Alex K on 8/1/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

import UIKit
import FirebaseDatabase

let kInvalidPathCharacters = try! NSRegularExpression(pattern: #"[\[\]\.\#\$\s]"#);

class Storage: NSObject {

    var ref: DatabaseReference?
    static var instance: Storage?

    override init() {
        super.init()
        self.ref = Database.database().reference()
    }

    static func getInstance() -> Storage {
        guard let databaseInstance = instance else {
            let databaseInstance = Storage()
            instance = databaseInstance
            return databaseInstance
        }
        instance = databaseInstance
        return databaseInstance
    }

    static func validatePath(_ path: String) -> Bool {
        if (path.isEmpty) {
            return false
        }
        
        let range = NSRange(location: 0, length: path.utf8.count)
        let match = kInvalidPathCharacters.firstMatch(in: path, options: [], range: range)
        return match == nil
    }

}
