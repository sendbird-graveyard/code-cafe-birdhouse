//
//  ChannelViewController.swift
//  Birdhouse
//
//  Created by Minhyuk Kim on 2021/10/14.
//

import UIKit
import SendBirdCalls
import SendBirdUIKit

class ChannelViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var titleLabel: UILabel!
    
    var room: Room!
    
    var localParticipantIndex: IndexPath? {
        return room.participants
            .firstIndex(where: { $0 is LocalParticipant })
            .map { IndexPath(row: $0, section: 0) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        titleLabel.text = room.title
        
        // MARK: - Set Room Delegate
        room.addDelegate(self, identifier: room.roomId)
    }
    
    // MARK: - Exit a Room
    @IBAction func leave(_ sender: Any) {
        do {
            try room.exit()
            self.dismiss(animated: true, completion: nil)
        } catch {
            print("Exiting with error: \(error)")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func muteMicrophone(_ sender: UIButton) {
        if room.localParticipant?.isAudioEnabled == true {
            room.localParticipant?.muteMicrophone()
            sender.setImage(.init(
                systemName: "mic.slash.fill",
                withConfiguration: UIImage.SymbolConfiguration(scale: .large)
            ), for: .normal)
        } else {
            room.localParticipant?.unmuteMicrophone()
            sender.setImage(.init(
                systemName: "mic.fill",
                withConfiguration: UIImage.SymbolConfiguration(scale: .large)
            ), for: .normal)
        }
        
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: [localParticipantIndex].compactMap { $0 })
        }
    }
    
    @IBAction func showChat(_ sender: Any) {
        // MARK: - Show Chat using UIKit
        SBDGroupChannel.getWithUrl(room.roomId) { channel, error in
            guard let channel = channel, error == nil else { return }
            
            channel.join { error in
                guard error == nil else { return }

                self.showUIKit(channel: channel)
            }
        }
    }
    
    func showUIKit(channel: SBDGroupChannel) {
        let viewController = SBUChannelViewController(channel: channel, messageListParams: .init())
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true)
    }
}

extension ChannelViewController: RoomDelegate {
    func didRemoteParticipantExit(_ participant: RemoteParticipant) {
        collectionView.reloadData()
    }
    
    func didRemoteParticipantEnter(_ participant: RemoteParticipant) {
        collectionView.reloadData()
    }
}

extension ChannelViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "participant", for: indexPath) as! ParticipantCell
        
        // MARK: - Show Participant Cell
        let participant = room.participants[indexPath.row]
        cell.participant = participant
        
        room.addDelegate(cell, identifier: participant.participantId)
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return room.participants.count
    }
    
    // MARK: - Select other users to start a DM
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let participant = room.participants[indexPath.row]
        guard participant is RemoteParticipant else { return }
        
        let controller = UIAlertController(title: participant.user.nickname ?? participant.user.userId, message: nil, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Direct Message", style: .default, handler: { _ in
            let params = SBDGroupChannelParams()
            params.addUserId(participant.user.userId)
            params.isDistinct = true
            SBDGroupChannel.createChannel(with: params) { channel, error in
                guard let channel = channel, error == nil else { return }
                
                self.showUIKit(channel: channel)
            }
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(controller, animated: true, completion: nil)
    }
}
