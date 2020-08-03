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
    func addNewTopic(with title: String)
    func remove(topic: Topic)
}

class RoomManager: RoomManagerType {

    let service: DbService
    weak var view: TopicsViewType?

    deinit {
        service.unsubscribeForUpdates()
    }

    init(service: DbService) {
        self.service = service
        self.service.observer = self
    }

    func fetch() {
        view?.showLoading()
        service.fetchRoomInfo { [weak self] (room, error) in
            if let error = error {
                DispatchQueue.main.async { [weak self] in
                    self?.view?.hideLoading()
                    self?.handle(error: error)
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
            self?.service.subscribeForUpdates()
            DispatchQueue.main.async { [weak self] in
                self?.view?.hideLoading()
                //                    self?.view?.reload(topics: topics)
            }
        }
    }

    func update(topic: Topic) {
        service.update(topic: topic) {
            DispatchQueue.main.async { [weak self] in
                self?.view?.update(topic: topic)
            }
        }
    }

    func insert(topic: Topic) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.insert(topic: topic, at: IndexPath(row: 0, section: 0))
        }

    }

    func addNewTopic(with title: String) {
        service.createTopic(with: title) {  (_, _) in

        }
    }

    func remove(topic: Topic) {
        view?.delete(topic: topic)
        service.remove(topic: topic)
    }

    func handle(error: ServiceError) {
        switch error {
        case .roomNotExist:
            self.view?.showAlert(with: "Room Not Exist", completion: {
                self.view?.popNavigation()
            })
        case .firebaseIssue(let message):
            self.view?.showAlert(with: "Firebase problem.\(message)", completion: {
                self.view?.popNavigation()
            })
        case .unableToCreateRoom:
            self.view?.showAlert(with: "Unable to create room.", completion: {
                self.view?.popNavigation()
            })
        case .topicNotExist:
            self.view?.showAlert(with: "Can't create toppic.", completion: {
                self.view?.popNavigation()
            })
        }
    }
}
