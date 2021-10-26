//
//  ChannelManager.swift
//  Birdhouse
//
//  Created by Minhyuk Kim on 2021/10/25.
//

import Foundation
import SendBirdSDK
import SendBirdCalls

extension Room {
    var title: String? {
        return "Room"
    }
}
//
//class ChannelManager {
//    static let shared = ChannelManager()
//    
//    var rooms: [Room] = []
//    
//    var query: RoomListQuery?
//    
//    init() {
//        self.query = createRoomQuery()
//    }
//    
//    func resetChannels() {
//        self.rooms = []
//        self.query = createRoomQuery()
//    }
//    
//    func getRoom(index: Int) -> Room {
//        return rooms[index]
//    }
//    
//    func getChannel(_ channelId: String, completionHandler: (((Room, SBDGroupChannel)?, Error?) -> Void)?) {
//        let room = SendBirdCall.getCachedRoom(by: channelId)
//        SBDGroupChannel.getWithUrl(channelId) { channel, error in
//            guard let room = room, let channel = channel, error == nil else {
//                completionHandler?(nil, error)
//                return
//            }
//            
//            completionHandler?((room, channel), nil)
//        }
//    }
//}
