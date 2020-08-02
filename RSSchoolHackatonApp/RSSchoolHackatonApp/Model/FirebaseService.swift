//
//  FirebaseService.swift
//  RSSchoolHackatonApp
//
//  Created by Arseniy Strakh on 02.08.2020.
//  Copyright © 2020 Alex K. All rights reserved.
//

import Foundation



protocol ServiceObserver: AnyObject {
    func update()
}

protocol Observable {
    var observers: [ServiceObserver] { get }
    func add(observer: ServiceObserver)
    func remove(observer: ServiceObserver)
}

class FirebaseService: Observable {

    var observers: [ServiceObserver] = []

    func add(observer: ServiceObserver) {
        observers.append(observer)
    }

    func remove(observer: ServiceObserver) {
        observers.removeAll { (serviceObserver) -> Bool in
            serviceObserver === observer
        }
    }

    
    func fetch(completion:([Topic]) -> ()) {

    }
    func update(topic: Topic) {

    }
    func add(topic: Topic) {

    }
    func remove(topic: Topic) {

    }
}
