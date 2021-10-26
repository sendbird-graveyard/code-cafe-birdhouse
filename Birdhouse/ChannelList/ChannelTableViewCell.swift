//
//  ChannelTableViewCell.swift
//  Birdhouse
//
//  Created by Minhyuk Kim on 2021/10/19.
//

import UIKit
import SendBirdSDK
import SendBirdCalls

class ChannelTableViewCell: UITableViewCell {
    static let identifier = "ChannelTableViewCell"
    
    @IBOutlet weak var coverImageView: UIImageView! {
        didSet {
            coverImageView.layer.cornerRadius = coverImageView.frame.height / 2
            coverImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var participantStackView: UIStackView!
    @IBOutlet weak var participantCountLabel: UILabel!
    
    // MARK: Room
    var room: Room? {
        didSet {    
//            setupUI()
            // ParticipantStackView
            //room!.participants.forEach { participant in
            for participant in ["hey", "ho", "this is noce", "good"] {
                if participantStackView.arrangedSubviews.count <= 4 {
                    let label = UILabel()
                    label.text = participant// .user.nickname?.collapsed ?? participant.user.userId
                    label.font = UIFont(name: "Gellix-SemiBold", size: 13)
                    label.sizeToFit()
                    participantStackView.addArrangedSubview(label)
                }
            }
            
            
            // Participants count
            participantCountLabel.text = String(room!.participants.count)
            channelTitleLabel.text = room?.title
//            loadChannel()
        }
    }
//    // MARK: Channel
//    var channel: SBDGroupChannel? {
//        didSet {
//
//                if let coverURL = channel?.coverUrl {
//                    coverImageView.updateImage(urlString: coverURL)
//                }
//
//
//
////            setupUI()
////            updateUI()
//        }
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        participantStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//        coverImageView.image = nil
    }
    
//    func loadChannel() {
//        guard let room = room else { return }
//        SBDGroupChannel.getWithUrl(room.roomId) { channel, error in
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//            self.channel = channel
//        }
//    }
//
//
    func setupUI() {
        // placeholders
    }
  
    /// Update UI. If channel or room is nil, the app will be ended.
    func updateUI() {
        
        
    }
}
