//
//  ChannelHistoryResponse.swift
//  SocialGraph
//
//  Created by fnord on 2/15/21.
//

import Foundation

struct ResponseMetadata: Codable {
  let nextCursor: String
}

struct ChannelHistoryResponse: Codable {
  let ok: Bool
  let hasMore: Bool
  let responseMetadata: ResponseMetadata?
  let messages: [Message]
}
