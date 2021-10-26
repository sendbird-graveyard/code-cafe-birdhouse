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

class ChannelManager {
    static let shared = ChannelManager()
    
    var rooms: [Room] = []
    var channels: [String: SBDGroupChannel] = [:]
    
    var query: RoomListQuery?
    
    init() {
        self.query = createRoomQuery()
    }
    
    func resetChannels() {
        self.rooms = []
        self.channels = [:]
        self.query = createRoomQuery()
    }
    
    func getChannel(index: Int) -> (Room, SBDGroupChannel)? {
        let room = rooms[index]
        guard let channel = channels[room.roomId] else {
            return nil
        }
        
        return (room, channel)
    }
    func getChannel(_ channelId: String, completionHandler: (((Room, SBDGroupChannel)?, Error?) -> Void)?) {
        let room = SendBirdCall.getCachedRoom(by: channelId)
        SBDGroupChannel.getWithUrl(channelId) { channel, error in
            guard let room = room, let channel = channel, error == nil else {
                completionHandler?(nil, error)
                return
            }
            
            completionHandler?((room, channel), nil)
        }
    }
    
    func loadChannels(completionHandler: (([Room]?, Error?) -> Void)? =  nil) {
        guard let query = query ?? createRoomQuery() else {
            assertionFailure("Cannot create room query because SendBirdCalls SDK is not connected.")
            return
        }
        
        query.next { rooms, error in
            guard let rooms = rooms else { return }
            
            self.rooms.append(contentsOf: rooms)
            
            let mutex = DispatchSemaphore(value: 1)
            let group = DispatchGroup()
            for room in rooms {
                SBDGroupChannel.getWithUrl(room.roomId) { channel, error in
                    defer { group.leave() }
                    guard let channel = channel, error == nil else { return }
                    self.channels[room.roomId] = channel
//                    mutex.signal()
                }
                group.enter()
//                mutex.wait()
            }
            group.notify(queue: DispatchQueue.global(qos: .userInteractive)) {
                DispatchQueue.main.async {
                completionHandler?(rooms, error)
                }
            }
        }
    }
    
    func createRoomQuery() -> RoomListQuery? {
        let params = RoomListQuery.Params()
            .setType(.largeRoomForAudioOnly)
            .setState(.open)
        query = SendBirdCall.createRoomListQuery(with: params)
        return query
    }
    
    func createRoom(title: String, completionHandler: (() -> Void)?) {
        let params = RoomParams(roomType: .largeRoomForAudioOnly)
        SendBirdCall.createRoom(with: params) { room, error in
            guard let room = room, error == nil else {
                return
            }
            
            let channelParams = SBDGroupChannelParams()
            channelParams.channelUrl = room.roomId
            channelParams.isPublic = true
            SBDGroupChannel.createChannel(with: channelParams) { groupChannel, error in
                guard let groupChannel = groupChannel, error == nil else { return }
                
                self.rooms.append(room)
                self.channels[room.roomId] = groupChannel
                completionHandler?()
//                self.tableView.reloadData()
            }
        }
    }
}
