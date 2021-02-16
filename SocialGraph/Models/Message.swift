//
//  Message.swift
//  SocialGraph
//
//  Created by fnord on 2/15/21.
//

import Foundation

struct Message: Codable {
  let type: String
  let user: String
  let text: String
  let ts: String
  let replyCount: Int?
  let threadTs: String?
  
  var date: Date {
    guard let timestamp = Double(ts) else { fatalError() }
    return Date(timeIntervalSince1970: timestamp)
  }
}
