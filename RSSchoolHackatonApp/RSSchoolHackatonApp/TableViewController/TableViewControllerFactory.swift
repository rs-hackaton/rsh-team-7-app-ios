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

    static func make(room: Room) -> TableViewController {
        let tableViewController = self.fromStoryboard()
        tableViewController.room = room
        let service = FirebaseService()
        let manager = RoomManager(service: service, room: room)
        tableViewController.manager = manager
        manager.view = tableViewController
        return tableViewController
    }
}
