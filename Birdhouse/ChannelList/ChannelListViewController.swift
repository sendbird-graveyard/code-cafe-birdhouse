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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshRoomList(sender:)), for: .valueChanged)
        refreshControl.attributedTitle = .init(string: "Reloading room list...")
        tableView.refreshControl = refreshControl
        
        let logOut = UIAction(title: "Log out", attributes: .destructive) { _ in
            self.rooms.removeAll()
            self.createRoomQuery()
            
            self.performSegue(withIdentifier: "logout", sender: nil)
        }
        settingsButton.menu = UIMenu(
            title: "User Id: \(SBDMain.getCurrentUser()?.userId ?? "") \n Nickname: \(SBDMain.getCurrentUser()?.nickname ?? "")",
            options: .displayInline,
            children: [logOut]
        )
        
        loadChannels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadChannels()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ChannelViewController,
           let room = sender as? Room {
            destination.room = room
        }
    }
    
    // MARK: - Create Room
    @IBAction func createRoom(_ sender: Any) {
        let alert = UIAlertController(title: "Create a room", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Room name"
        }
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak alert] _ in
            let textField = alert!.textFields![0]
            let name = textField.text ?? "Audio Room"

            self.createRoom(title: name) { room in
                self.enterRoom(room: room)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    func createRoom(title: String, completionHandler: ((Room) -> Void)?) {
        let params = RoomParams(roomType: .largeRoomForAudioOnly)
        params.customItems = ["title": title]
        SendBirdCall.createRoom(with: params) { room, error in
            guard let room = room, error == nil else {
                return
            }
            
            let channelParams = SBDGroupChannelParams()
            channelParams.channelUrl = room.roomId
            channelParams.name = title
            channelParams.isPublic = true
            SBDGroupChannel.createChannel(with: channelParams) { groupChannel, error in
                guard groupChannel != nil, error == nil else { return }
                
                self.rooms.insert(room, at: 0)
                self.tableView.reloadData()
                completionHandler?(room)
            }
        }
    }
    
    // MARK: - Enter Room
    func enterRoom(room: Room) {
        let params = Room.EnterParams(isAudioEnabled: false)
        room.enter(with: params) { roomError in
            guard roomError == nil else { return }
            self.performSegue(withIdentifier: "joinRoom", sender: room)
        }
    }
    
    // MARK: - Query Room
    @discardableResult
    func createRoomQuery() -> RoomListQuery? {
        let params = RoomListQuery.Params()
            .setType(.largeRoomForAudioOnly)
            .setState(.open)
        query = SendBirdCall.createRoomListQuery(with: params)
        return query
    }
    
    func loadChannels(completionHandler: (() -> Void)? = nil) {
        guard let query = query ?? createRoomQuery() else {
            assertionFailure("Cannot create room query because SendBirdCalls SDK is not connected.")
            return
        }
        
        guard !query.isLoading, query.hasNext else { return }
        query.next { rooms, error in
            guard let rooms = rooms else { return }
            
            self.rooms.append(contentsOf: rooms)
            self.tableView.reloadData()
            completionHandler?()
        }
    }
    
    @objc
    func refreshRoomList(sender: UIRefreshControl) {
        rooms.removeAll()
        query = nil
        tableView.reloadData()
        loadChannels {
            sender.endRefreshing()
        }
    }
}

extension ChannelListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            loadChannels()
        }
    }
}
