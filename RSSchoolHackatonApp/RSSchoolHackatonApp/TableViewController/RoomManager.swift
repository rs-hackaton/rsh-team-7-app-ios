//
//  RoomManager.swift
//  RSSchoolHackatonApp
//
//  Created by Arseniy Strakh on 02.08.2020.
//  Copyright © 2020 Alex K. All rights reserved.
//

import Foundation

protocol RoomManagerType: ServiceObserver {
    func fetch()
    func update(topic: Topic)
    func add(topic: Topic)
    func remove(topic: Topic)
}

class RoomManager: RoomManagerType {

    let service: FirebaseService
    weak var view: TopicsView?

    init(service: FirebaseService = FirebaseService(), room: Room) {
        self.service = service
        service.add(observer: self)
    }

    func update() {

    }

    func fetch() {

    }

    func fetch(completion: ([Topic]) -> Void) {

    }

    func update(topic: Topic) {

    }

    func add(topic: Topic) {

    }

    func remove(topic: Topic) {

    }

}
