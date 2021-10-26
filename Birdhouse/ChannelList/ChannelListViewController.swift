//
//  ChannelListViewController.swift
//  Birdhouse
//
//  Created by Minhyuk Kim on 2021/10/14.
//

import UIKit
import SendBirdSDK
import SendBirdCalls

class ChannelListViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var settingsButton: UIButton!
    
    var rooms: [Room] = []
    var query: RoomListQuery?
    
    func loadChannels(completionHandler: (() -> Void)? = nil) {
        guard let query = query ?? createRoomQuery() else {
            assertionFailure("Cannot create room query because SendBirdCalls SDK is not connected.")
            return
        }
        
        guard !query.isLoading, query.hasNext else { return }
        query.next { rooms, error in
            guard let rooms = rooms else { return }
            
            self.rooms.append(contentsOf: rooms)
            
            completionHandler?()
        }
    }
    
    @discardableResult
    func createRoomQuery() -> RoomListQuery? {
        let params = RoomListQuery.Params()
            .setType(.largeRoomForAudioOnly)
            .setState(.open)
        query = SendBirdCall.createRoomListQuery(with: params)
        return query
    }
    
    func createRoom(title: String, completionHandler: ((Room) -> Void)?) {
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
                
                self.rooms.insert(room, at: 0)
                self.tableView.reloadData()
                completionHandler?(room)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        let logOut = UIAction(title: "Log out", attributes: .destructive) { _ in
            self.rooms.removeAll()
            self.createRoomQuery()
            
            self.performSegue(withIdentifier: "logout", sender: nil)
        }
        settingsButton.menu = UIMenu(
            title: SendBirdCall.currentUser?.userId ?? "",
            options: .displayInline,
            children: [logOut]
        )
        
        loadChannels {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadChannels {
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ChannelViewController,
           let room = sender as? Room {
            destination.room = room
        }
    }
    
    @IBAction func createRoom(_ sender: Any) {
        let alert = UIAlertController(title: "Create a room", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Room name"
        }
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak alert] _ in
            let textField = alert!.textFields![0]
            let name = textField.text ?? "Audio Room"

            self.createRoom(title: name) { room in
                self.tableView.reloadData()
                self.enterRoom(room: room)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))

        self.present(alert, animated: true, completion: nil)
        
//        let params = RoomParams(roomType: .largeRoomForAudioOnly)
//        SendBirdCall.createRoom(with: params) { room, error in
//            guard let room = room, error == nil else {
//                return
//            }
//
//            let channelParams = SBDGroupChannelParams()
//            channelParams.channelUrl = room.roomId
//            SBDGroupChannel.createChannel(with: channelParams) { groupChannel, error in
//                guard let groupChannel = groupChannel, error == nil else { return }
//
//                self.rooms.append(room)
//                self.tableView.reloadData()
//            }
//        }
    }
//
//    func loadChannels(completionHandler: (([Room]?, Error?) -> Void)? = nil) {
//        guard let query = query ?? createRoomQuery() else {
//            assertionFailure("Cannot create room query because SendBirdCalls SDK is not connected.")
//            return
//        }
//
//        query.next { rooms, error in
//            if let rooms = rooms {
//                self.rooms.append(contentsOf: rooms)
//            }
//            completionHandler?(rooms, error)
//        }
//    }
//
//    func createRoomQuery() -> RoomListQuery? {
//        let params = RoomListQuery.Params()
//            .setType(.largeRoomForAudioOnly)
//            .setState(.open)
//        query = SendBirdCall.createRoomListQuery(with: params)
//        return query
//    }
////
//    func loadChannelList(resultHandler: @escaping (Result<[SBDGroupChannel], Error>) -> Void) {
//        // TODO: Init SBDGroupChannelListQuery
//        channelListQuery = SBDGroupChannel.createPublicGroupChannelListQuery()
//
//        channelListQuery?.channelUrlsFilter = self.rooms.compactMap { $0.roomId }
//        channelListQuery?.limit = 20
//        channelListQuery?.loadNextPage { channels, error in
//            if let error = error {
//                resultHandler(.failure(error))
//                return
//            }
//            resultHandler(.success(channels ?? []))
//        }
//    }
    
    func enterRoom(room: Room) {
        let params = Room.EnterParams()
        room.enter(with: params) { roomError in
            guard roomError == nil else { return }
            self.performSegue(withIdentifier: "joinRoom", sender: room)
        }
    }
}

extension ChannelListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count// rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChannelTableViewCell.identifier, for: indexPath) as! ChannelTableViewCell
        
        let room = rooms[indexPath.row]
        cell.room = room
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = rooms[indexPath.row]
        enterRoom(room: room)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65 + CGFloat(rooms[indexPath.row].participants.count * 12)
    }
   
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row > rooms.count - 1 else { return }
        loadChannels {
            print("Reloading again")
            tableView.reloadData()
        }
    }
}
