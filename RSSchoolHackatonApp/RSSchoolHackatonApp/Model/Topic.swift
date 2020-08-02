//
//  Topic.swift
//  RSSchoolHackatonApp
//
//  Created by Arseniy Strakh on 01.08.2020.
//  Copyright © 2020 Alex K. All rights reserved.
//

import Foundation

struct Topic {
    let id: String
    var title = ""
    var time = Date()
    var roomId = ""
    var active: Bool = false
    var order: Int = 0
    var userId: String = ""
    
    static func fromDict(_ topicAsDict: Dictionary<String, Any>, id: String) -> Topic {
        let title = topicAsDict["title"] as? String ?? ""
        let time = Date(timeIntervalSince1970: TimeInterval(Double(topicAsDict["time"] as? String ?? "") ?? 0))
        let active = Bool(topicAsDict["active"] as? String ?? "false") ?? false
        let order = Int(topicAsDict["active"] as? String ?? "0") ?? 0
        let roomId = topicAsDict["roomId"] as? String ?? ""
        let userId = topicAsDict["userId"] as? String ?? ""
        let topic = Topic(id: id, title: title, time: time, roomId: roomId, active: active, order: order, userId: userId)
        return topic
    }
}
