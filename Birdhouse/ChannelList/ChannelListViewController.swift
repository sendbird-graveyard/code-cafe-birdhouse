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
    
    // MARK: Room
    var rooms: [Room] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var query: RoomListQuery?
    
    // MARK: SBDGroupChannel
    var channels: [SBDGroupChannel] = []
    var channelListQuery: SBDPublicGroupChannelListQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        
        let logOut = UIAction(title: "Log out", attributes: .destructive) { _ in
            ChannelManager.shared.resetChannels()
            self.performSegue(withIdentifier: "logout", sender: nil)
        }
        
//        tableView.register(ChannelTableViewCell.self, forCellReuseIdentifier: ChannelTableViewCell.identifier)
//        tableView.register(UINib(nibName: "ChannelTableViewCell", bundle: nil), forCellReuseIdentifier: ChannelTableViewCell.identifier)
        settingsButton.menu = UIMenu(title: SendBirdCall.currentUser?.userId ?? "", options: .displayInline, children: [logOut])
        
        ChannelManager.shared.loadChannels { _, _ in
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        ChannelManager.shared.resetChannels()
        ChannelManager.shared.loadChannels()
//        self.rooms.removeAll()
//        loadChannels()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ChannelViewController,
           let room = sender as? Room {
            destination.room = room
//            destination.channel = channel
        }
    }
    
    @IBAction func createRoom(_ sender: Any) {
        let alert = UIAlertController(title: "Create a room", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = "Room name"
        }
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak alert] _ in
            let textField = alert!.textFields![0]
            let name = textField.text ?? "Audio Room"
            ChannelManager.shared.createRoom(title: name) { room in
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
}

extension ChannelListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChannelManager.shared.rooms.count// rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChannelTableViewCell.identifier, for: indexPath) as! ChannelTableViewCell
        
        let room = ChannelManager.shared.getRoom(index: indexPath.row)
        
        cell.room = room
//        cell.channel = channel
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = ChannelManager.shared.getRoom(index: indexPath.row)
        enterRoom(room: room)
    }
    
    func enterRoom(room: Room) {
        let params = Room.EnterParams()
        room.enter(with: params) { roomError in
            guard roomError == nil else { return }
            self.performSegue(withIdentifier: "joinRoom", sender: room)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55 + 4 * 12
    }
}
