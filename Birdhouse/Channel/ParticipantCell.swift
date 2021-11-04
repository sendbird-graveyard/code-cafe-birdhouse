//
//  ParticipantCell.swift
//  Birdhouse
//
//  Created by Minhyuk Kim on 2021/10/27.
//

import UIKit
import SendBirdCalls

class ParticipantCell: UICollectionViewCell {
    
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var audioMutedImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var participant: Participant? {
        didSet {
            guard let participant = participant else { return }
            updateView(with: participant)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.participant = nil
    }
    
    // MARK: - Configure Cell with Participant information
    func updateView(with participant: Participant) {
        userIdLabel.text = "\(participant.user.nickname?.collapsed ?? participant.user.userId)"
        audioMutedImageView.isHidden = participant.isAudioEnabled

        profileImageView.updateImage(urlString: participant.user.profileURL)
        
        if participant is LocalParticipant {
            profileImageView.layer.borderColor = UIColor.systemPurple.cgColor
        }
    }
}

extension ParticipantCell: RoomDelegate {
    func didRemoteAudioSettingsChange(_ participant: RemoteParticipant) {
        guard participant.participantId == self.participant?.participantId else { return }
        
        updateView(with: participant)
    }
}
