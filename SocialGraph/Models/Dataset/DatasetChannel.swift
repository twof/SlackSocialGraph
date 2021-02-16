//
//  DatasetChannel.swift
//  SocialGraph
//
//  Created by fnord on 2/15/21.
//

import Foundation

struct DatasetChannel: Encodable {
  let id: String
  let name: String
  /// ts: message
  var messages: [String: DatasetMessage]
}
