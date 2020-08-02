//
//  RoomService.swift
//  RSSchoolHackatonApp
//
//  Created by Arseniy Strakh on 02.08.2020.
//  Copyright © 2020 Alex K. All rights reserved.
//

import Foundation
import FirebaseAuth

enum ServiceError: Error {
    case roomNotExist
    case firebaseIssue(message: String)
    case unableToCreateRoom
}

protocol ServiceObserver: AnyObject {
    func update()
}

protocol Observable {
    var observers: [ServiceObserver] { get }
    func add(observer: ServiceObserver)
    func remove(observer: ServiceObserver)
}

protocol RoomServiceType: Observable {
    func createRoom(with title: String, completion:  @escaping (Room?, ServiceError?) -> Void)
    func fetchRoomInfo(completion: @escaping (Room?, ServiceError?) -> Void)
    func fetch(completion: ([Topic]) -> Void)
    func update(topic: Topic)
    func add(topic: Topic)
    func remove(topic: Topic)
}

class RoomService: RoomServiceType {

    // MARK: -

    var room: Room?
    var roomId: String?
    var roomTitle: String?
    var userId: String? {
         Auth.auth().currentUser?.uid
    }

    init(roomId: String) {
        self.roomId = roomId
    }
    init(title: String) {
        self.roomTitle = title
    }

    // MARK: - Observable
    var observers: [ServiceObserver] = []

    func add(observer: ServiceObserver) {
        observers.append(observer)
    }

    func remove(observer: ServiceObserver) {
        observers.removeAll { (serviceObserver) -> Bool in
            serviceObserver === observer
        }
    }

    // MARK: - RoomServiceType

    func createRoom(with title: String, completion: @escaping (Room?, ServiceError?) -> Void) {
        guard let userId = userId else {
            completion(nil, .firebaseIssue(message: "Can't get user Id."))
            return
        }
        Storage.getInstance().ref?.child("rooms").childByAutoId().setValue([
            "title": title,
            "userId": userId,
            "time": String(Date().timeIntervalSince1970)
            ], withCompletionBlock: { (error, ref) in
                if error != nil {
                    completion(nil, .firebaseIssue(message: "\(error!.localizedDescription)"))
                    return
                } else {
                    ref.observe(.value) { [weak self] (snapshot) in
                        guard let value = snapshot.value as? NSDictionary else {
                            completion(nil, .roomNotExist)
                            return
                        }
                        let title = value["title"] as? String ?? ""
                        let room = Room(id: snapshot.key, title: title, userId: userId, time: Date())
                        self?.roomId = snapshot.key
                        completion(room, nil)
                    }
                }
        })
    }

    func fetchRoomInfo(completion: @escaping (Room?, ServiceError?) -> Void) {
        guard let userId = userId else {
            completion(nil, .firebaseIssue(message: "Can't get user Id."))
            return
        }
        guard let roomId = roomId, !roomId.isEmpty else {
            if let title = roomTitle, !title.isEmpty {
                createRoom(with: title, completion: completion)
            } else {
                completion(nil, .firebaseIssue(message: "Room id and room title are nil"))
            }
            return
        }
        Storage.getInstance().ref?.child("rooms").child(roomId).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else {
                completion(nil, .roomNotExist)
                return
            }
//            let id = value["id"] as? String ?? NSUUID().uuidString
            let title = value["title"] as? String ?? ""
            let room = Room(id: snapshot.key, title: title, userId: userId, time: Date())
            completion(room, nil)
        }) {
            print($0.localizedDescription)
            completion(nil, .firebaseIssue(message: ""))
        }
    }

    func fetch(completion: ([Topic]) -> Void) {
        completion([])
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
