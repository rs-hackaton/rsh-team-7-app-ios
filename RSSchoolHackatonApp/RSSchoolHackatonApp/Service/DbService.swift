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
    case topicNotExist
    case roomNotExist
    case firebaseIssue(message: String)
    case unableToCreateRoom
}

protocol ServiceObserver: AnyObject {
    func insert(topic: Topic)
    func update(topic: Topic)
    func remove(topic: Topic)
}

protocol Observable {
    var observer: ServiceObserver? { get }
}

protocol RoomServiceType: Observable {
    func createRoom(with title: String, completion:  @escaping (Room?, ServiceError?) -> Void)
    func createTopic(with topic: String, completion:  @escaping (Topic?, ServiceError?) -> Void)
    func update(topic: Topic, completion: @escaping () -> Void)
    func fetchRoomInfo(completion: @escaping (Room?, ServiceError?) -> Void)
    func fetch(completion: @escaping ([Topic]) -> Void)
    func subscribeForUpdates()
    func unsubscribeForUpdates()
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

    func createTopic(with title: String, completion: @escaping (Topic?, ServiceError?) -> Void) {
        guard let userId = userId else {
            completion(nil, .firebaseIssue(message: "Can't get user Id."))
            return
        }
        guard let roomId = roomId else {
            completion(nil, .firebaseIssue(message: "Can't get room Id."))
            return
        }
        guard let ref = Storage.getInstance().ref else {
            completion(nil, .firebaseIssue(message: "Can't get storage."))
            return
        }
        ref.child("topics").childByAutoId().setValue([
            "active": false,
            "order": 0,
            "roomId": roomId,
            "time": String(Date().timeIntervalSince1970),
            "title": title,
            "userId": userId
            ], withCompletionBlock: { (error, ref) in
                if error != nil {
                    completion(nil, .firebaseIssue(message: "\(error!.localizedDescription)"))
                    return
                } else {
                    ref.observe(.value) { (snapshot) in
                        guard let dict = snapshot.value as? [String: Any] else {
                            completion(nil, .topicNotExist)
                            return
                        }
                        let topic = Topic.fromDict(dict, id: snapshot.key)
                        completion(topic, nil)
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
            let title = value["title"] as? String ?? ""
            let room = Room(id: snapshot.key, title: title, userId: userId, time: Date())
            completion(room, nil)
        }) {
            print($0.localizedDescription)
            completion(nil, .firebaseIssue(message: ""))
        }
    }

    func fetch(completion: @escaping ([Topic]) -> Void) {
        guard let roomId = roomId, !roomId.isEmpty else {
            return
        }
        Storage.getInstance().ref?.child("topics").queryOrdered(byChild: "roomId").queryEqual(toValue: roomId).observeSingleEvent(of: .value, with: { (snapshot) in
            print("Snapshot value: \(String(describing: snapshot.value))")
            guard let value = snapshot.value as? [String: [String: Any]] else {
                completion([])
                return
            }
            let topics: [Topic] = value.map {key, topicAsDict in
                let topic = Topic.fromDict(topicAsDict, id: key)

                return topic
            }
            completion(topics)

        }) {
            print($0.localizedDescription)
        }
    }
    // MARK: - Observable
    weak var observer: ServiceObserver?

    var addObserverHandle: UInt = 0
    var removeObserverHandle: UInt = 0
    var changeObserverHandle: UInt = 0

    func subscribeForUpdates() {
        guard let ref = Storage.getInstance().ref else { return }
        addObserverHandle = ref.child("topics").queryOrdered(byChild: "roomId").queryEqual(toValue: roomId).observe(.childAdded, with: { [weak self] (snapshot) in
            guard let dict = snapshot.value as? [String: Any] else {
                return
            }
            let topic = Topic.fromDict(dict, id: snapshot.key)
            self?.observer?.insert(topic: topic)
            print("Add listener: \(String(describing: snapshot.value))")

        })
        removeObserverHandle = ref.child("topics").queryOrdered(byChild: "roomId").queryEqual(toValue: roomId).observe(.childRemoved, with: {[weak self]  (snapshot) in
            guard let dict = snapshot.value as? [String: Any] else {
                return
            }
            let topic = Topic.fromDict(dict, id: snapshot.key)
            self?.observer?.remove(topic: topic)
            print("Remove listener: \(String(describing: snapshot.value))")
        })
        changeObserverHandle = ref.child("topics").queryOrdered(byChild: "roomId").queryEqual(toValue: roomId).observe(.childChanged, with: {[weak self]  (snapshot) in
            guard let dict = snapshot.value as? [String: Any] else {
                return
            }
            let topic = Topic.fromDict(dict, id: snapshot.key)
            self?.observer?.update(topic: topic)
            print("Update listener: \(String(describing: snapshot.value))")
        })
    }

    func unsubscribeForUpdates() {
        guard let ref = Storage.getInstance().ref else { return }
        ref.removeObserver(withHandle: addObserverHandle)
        ref.removeObserver(withHandle: removeObserverHandle)
        ref.removeObserver(withHandle: changeObserverHandle)
    }

    // MARK: - 

    func update(topic: Topic, completion: @escaping () -> Void) {
        guard let ref = Storage.getInstance().ref else {
            return
        }
        ref.child("topics").child(topic.id).setValue([
            "active": topic.active,
            "order": topic.order,
            "roomId": topic.roomId,
            "time": String(topic.time.timeIntervalSince1970),
            "title": topic.title,
            "userId": topic.userId
            ], withCompletionBlock: { (error, _) in
                if error != nil {
                    return
                } else {
                    completion()
                }
        })
    }

    func remove(topic: Topic) {
        guard let ref = Storage.getInstance().ref else {
            return
        }
        ref.child("topics").child(topic.id).removeValue()
    }
}
