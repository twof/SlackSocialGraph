//
//  Dataset.swift
//  SocialGraph
//
//  Created by fnord on 2/15/21.
//

import Foundation

struct Dataset: Encodable {
  var channels: [String: DatasetChannel]
}
