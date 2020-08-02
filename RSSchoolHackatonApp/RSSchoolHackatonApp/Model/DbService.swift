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
    func fetch(completion: @escaping ([Topic]) -> Void)
    func subscribeForUpdates(onAdd: @escaping (Topic)-> Void, onRemove: @escaping (Topic) -> Void) -> () -> Void
    func update(topic: Topic)
    func add(topic: Topic)
    func remove(topic: Topic)
}

class DbService: RoomServiceType {

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

    func fetch(completion: @escaping ([Topic]) -> Void) {
        guard let userId = userId else {
            return
        }
        guard let roomId = roomId, !roomId.isEmpty else {
            return
        }
        Storage.getInstance().ref?.child("topics").queryOrdered(byChild: "roomId").queryEqual(toValue: roomId).observeSingleEvent(of: .value, with: { (snapshot) in
            print("Snapshot value: \(snapshot.value)")
            guard let value = snapshot.value as? Dictionary<String, Dictionary<String, Any>> else {
                return
            }
            let topics:[Topic] = value.map {key, topicAsDict in
                let title = topicAsDict["title"] as? String ?? ""
                let time = Date(timeIntervalSince1970: TimeInterval(Double(topicAsDict["time"] as? String ?? "") ?? 0))
                let active = Bool(topicAsDict["active"] as? String ?? "false") ?? false
                let order = Int(topicAsDict["active"] as? String ?? "0") ?? 0
                let topic = Topic(id: key, title: title, time: time, roomId: roomId, active: active, order: order, userId: userId)
                return topic
            }
            completion(topics)
        }) {
            print($0.localizedDescription)
        }
    }
    
    func subscribeForUpdates(onAdd: @escaping (Topic) -> Void, onRemove: @escaping (Topic) -> Void) -> () -> Void {
        guard let ref = Storage.getInstance().ref else { return {} }
        let addObserverHandle = ref.child("topics").queryOrdered(byChild: "roomId").queryEqual(toValue: roomId).observe(.childAdded, with: { (snapshot) in
            guard let dict = snapshot.value as? Dictionary<String, Any> else {
                return
            }
            let topic = Topic.fromDict(dict, id: snapshot.key)
            onAdd(topic)
            print("Add listener: \(snapshot.value)")
            
        })
        let removeObserverHandle = ref.child("topics").queryOrdered(byChild: "roomId").queryEqual(toValue: roomId).observe(.childRemoved, with: { (snapshot) in
            guard let dict = snapshot.value as? Dictionary<String, Any> else {
                return
            }
            let topic = Topic.fromDict(dict, id: snapshot.key)
            onRemove(topic)
            print("Remove listener: \(snapshot.value)")
        })
        return {
            ref.removeObserver(withHandle: addObserverHandle)
            ref.removeObserver(withHandle: removeObserverHandle)
        }
    }

    func update(topic: Topic) {
        print(#function)
    }
    func add(topic: Topic) {
        guard let userId = userId else {
            return
        }
        guard let roomId = roomId else {
            return
        }
        guard let ref = Storage.getInstance().ref else {
            return
        }
        ref.child("topics").childByAutoId().setValue([
            "active": false,
            "order": 0,
            "roomId": roomId,
            "time": String(Date().timeIntervalSince1970),
            "title": topic.title,
            "userId": userId,
            ], withCompletionBlock: { (error, ref) in
                guard error != nil else {
                    return
                }
                ref.observe(.value) { [weak self] (snapshot) in
                }
        })
    }
    func remove(topic: Topic) {
        print(#function)
    }
}
