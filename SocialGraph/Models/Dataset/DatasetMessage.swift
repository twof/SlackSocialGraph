//
//  DatasetMessage.swift
//  SocialGraph
//
//  Created by fnord on 2/15/21.
//

import Foundation

struct DatasetMessage: Encodable {
  let taggedUsers: [String]?
  var threadedMessages: [DatasetMessage]?
  let author: String
  let timestamp: Date
}
