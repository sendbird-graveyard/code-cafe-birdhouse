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
    
    var localParticipantIndex: [IndexPath] {
        if let index = self.room.participants.firstIndex(where: { $0 is LocalParticipant }) {
            return [IndexPath(row: index, section: 0)]
        }
        return []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        titleLabel.text = room.title
        
        room.addDelegate(self, identifier: room.roomId)
    }
    
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
            collectionView.reloadItems(at: localParticipantIndex)
        }
    }
    
    @IBAction func showChat(_ sender: Any) {
        let viewController = SBUChannelViewController(channelUrl: room.roomId, messageListParams: nil)
        self.present(viewController, animated: true, completion: nil)
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
}
