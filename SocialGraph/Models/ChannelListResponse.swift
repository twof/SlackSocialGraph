//
//  ChannelListResponse.swift
//  SocialGraph
//
//  Created by fnord on 2/15/21.
//

import Foundation

struct ChannelListResponse: Decodable {
  let ok: Bool
  let channels: [Channel]
}
