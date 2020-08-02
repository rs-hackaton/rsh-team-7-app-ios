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

    let service: RoomService
    weak var view: TopicsViewType?

    init(service: RoomService) {
        self.service = service
        service.add(observer: self)
    }

    func update() {

    }

    func fetch() {
        view?.showLoading()
        service.fetchRoomInfo { [weak self] (_, error) in
            if let error = error {
                print(error)
                self?.view?.hideLoading()
                switch error {
                case .roomNotExist:
                    self?.view?.showAlert(with: "Room Not Exist", completion: {
                        self?.view?.popNavigation()
                    })
                case .firebaseIssue, .unableToCreateRoom:
                    self?.view?.showAlert(with: "Firebase problem.", completion: {
                        self?.view?.popNavigation()
                    })
                }
                return
            }
            self?.service.fetch(completion: { (topics) in
                DispatchQueue.main.async { [weak self] in
                    self?.view?.hideLoading()
                    self?.view?.reload(topics: topics)
                }
            })
        }
    }

    func update(topic: Topic) {

    }

    func add(topic: Topic) {

    }

    func remove(topic: Topic) {

    }

}
