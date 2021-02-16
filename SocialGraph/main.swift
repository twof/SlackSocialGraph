
//
//  main.swift
//  SocialGraph
//
//  Created by fnord on 2/15/21.
//

import Foundation
import Promise

let slack = SlackService()
var dataset = Dataset(channels: [:])

func convert(range: NSRange, string: String) -> Range<String.Index> {
  return string.index(string.startIndex, offsetBy: range.location)..<string.index(string.startIndex, offsetBy: range.location+range.length)
}

func taggedUsers(message: String) -> [String]? {
  let regex = try! NSRegularExpression(pattern: #"\<\@([0-9!-z]*)\>"#, options: [])

  let matches = regex.matches(in: message, options: [], range: NSRange(location: 0, length: message.count))
  let userIds = matches.map { (result) in
    return String(message[convert(range: result.range(at: 1), string: message)])
  }
  
  return userIds == [] ? nil : userIds
}

slack.channelList().then { (response) -> Promise<[(String, ChannelHistoryResponse)]> in
  let getHistoryPromises = response.channels.map { channel -> Promise<(String, ChannelHistoryResponse)> in
    let datasetChannel = DatasetChannel(id: channel.id, name: channel.name, messages: [:])
    dataset.channels[channel.id] = datasetChannel

    return slack.messageHistory(channelId: channel.id).then { historyResponse in
      return (channel.id, historyResponse)
    }
  }

  return Promises.all(getHistoryPromises)
}.then { (channelIdHistories) -> Promise<[(String, String, ThreadRepliesResponse)]> in
  // go through each channel history
  let threadReplies = channelIdHistories.flatMap { channelIdHistory -> [Promise<(String, String, ThreadRepliesResponse)>] in
    let (channelId, history) = channelIdHistory
    // go through each message and check if it's a thread
    // return a promise if it is, and a
    return history.messages.compactMap { (message) -> Promise<(String, String, ThreadRepliesResponse)>? in
      dataset.channels[channelId]?.messages[message.ts] = DatasetMessage(
        taggedUsers: taggedUsers(message: message.text),
        threadedMessages: nil,
        author: message.user,
        timestamp: message.date
      )

      guard let timestamp = message.threadTs else { return nil }
      return slack.threadReplies(channel: channelId, messageTimestamp: timestamp).then { (channelId, timestamp, $0) }
    }
  }

  return Promises.all(threadReplies)
}.then { (channelTimestampReplies) in
  return channelTimestampReplies.map { something in
    let (channelId, timestamp, repliesResponse) = something
    dataset.channels[channelId]?.messages[timestamp]?.threadedMessages = repliesResponse.messages.map {
      DatasetMessage(
        taggedUsers: taggedUsers(message: $0.text),
        threadedMessages: nil,
        author: $0.user,
        timestamp: $0.date
      )
    }
  }
}.always {
  let encoder = JSONEncoder()
  let jsondata = try! encoder.encode(dataset)
  print(String(data: jsondata, encoding: .utf8)!)
}

dispatchMain()
