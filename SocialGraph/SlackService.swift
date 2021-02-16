//
//  SlackService.swift
//  SocialGraph
//
//  Created by fnord on 2/15/21.
//

import Foundation
import Promise

struct SlackService {
  let authKey = "xoxp-1635842316323-1641803808900-1767479202401-f2292503311f0fd728a5b09ccfd62925"
  let session = URLSession.shared
  
  func channelList() -> Promise<ChannelListResponse> {
    return request(url: "https://slack.com/api/conversations.list", decodeTo: ChannelListResponse.self)
  }
  
  func messageHistory(channelId: String) -> Promise<ChannelHistoryResponse> {
    let queryItems = [URLQueryItem(name: "channel", value: channelId)]
    return request(
      url: "https://slack.com/api/conversations.history",
      queryItems: queryItems,
      decodeTo: ChannelHistoryResponse.self
    )
  }
  
  func threadReplies(channel: String, messageTimestamp: String) -> Promise<ThreadRepliesResponse> {
    let queryItems = [
      URLQueryItem(name: "ts", value: messageTimestamp),
      URLQueryItem(name: "channel", value: channel)
    ]
    return request(
      url: "https://slack.com/api/conversations.replies",
      queryItems: queryItems,
      decodeTo: ThreadRepliesResponse.self
    )
  }
 
  private func request<T: Decodable>(
    url: String,
    queryItems: [URLQueryItem] = [],
    decodeTo type: T.Type
  ) -> Promise<T> {
    guard var urlComponents = URLComponents(string: url) else { fatalError() }
    urlComponents.queryItems = [URLQueryItem(name: "pretty", value: "1")] + queryItems
    
    guard let url = urlComponents.url else { fatalError() }
    var request = URLRequest(url: url)
    request.setValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .secondsSince1970

    return Promise(queue: .main) { (fullfill, reject) in
      session.dataTask(with: request) { data, response, error in
        if let error = error {
          return reject(error)
        }
        guard let data = data else { return }
        let decodedResponse = try! decoder.decode(type, from: data)
        fullfill(decodedResponse)
      }.resume()
    }
  }
}
