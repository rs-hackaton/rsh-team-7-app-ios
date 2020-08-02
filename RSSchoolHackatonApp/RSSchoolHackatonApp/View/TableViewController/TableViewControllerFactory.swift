//
//  TableViewControllerFactory.swift
//  RSSchoolHackatonApp
//
//  Created by Arseniy Strakh on 02.08.2020.
//  Copyright © 2020 Alex K. All rights reserved.
//

import UIKit

struct TableViewControllerFactory {

    static func fromStoryboard() -> TableViewController {
        let storyboard = UIStoryboard(name: "Table", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "TableViewController") as? TableViewController else {
            fatalError("Unable to instantiate TableViewController!")
        }
        return vc
    }

    static func make(roomId: String) -> TableViewController {
        let tableViewController = self.fromStoryboard()
        let service = DbService(roomId: roomId)
        let manager = RoomManager(service: service)
        tableViewController.manager = manager
        manager.view = tableViewController
        return tableViewController
    }

    static func make(title: String) -> TableViewController {
        let tableViewController = self.fromStoryboard()
        let service = DbService(title: title)
        let manager = RoomManager(service: service)
        tableViewController.manager = manager
        manager.view = tableViewController
        return tableViewController
    }
}
