//
//  ThreadRepliesResponse.swift
//  SocialGraph
//
//  Created by fnord on 2/15/21.
//

import Foundation

struct ThreadRepliesResponse: Codable {
  let hasMore: Bool
  let ok: Bool
  let responseMetadata: ResponseMetadata?
  let messages: [Message]
}
