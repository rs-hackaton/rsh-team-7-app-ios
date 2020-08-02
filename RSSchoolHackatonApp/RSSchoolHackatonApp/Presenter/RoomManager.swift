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
        service.fetchRoomInfo { [weak self] (room, error) in
            if let error = error {
                print(error)
                self?.view?.hideLoading()
                switch error {
                case .roomNotExist:
                    self?.view?.showAlert(with: "Room Not Exist", completion: {
                        self?.view?.popNavigation()
                    })
                case .firebaseIssue(let message):
                    self?.view?.showAlert(with: "Firebase problem.\(message)", completion: {
                        self?.view?.popNavigation()
                    })
                case .unableToCreateRoom:
                    self?.view?.showAlert(with: "Unable to create room.", completion: {
                        self?.view?.popNavigation()
                    })
                }
                return
            }
            guard let room = room else {
                DispatchQueue.main.async { [weak self] in
                    self?.view?.hideLoading()
                    self?.view?.showAlert(with: "Failed to get room") {
                        self?.view?.popNavigation()
                    }
                }
                return
            }
            DispatchQueue.main.async {
                self?.view?.update(with: room)
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
        print(#function)
    }

    func add(topic: Topic) {
        print(#function)
    }

    func remove(topic: Topic) {
        print(#function)
    }

}
