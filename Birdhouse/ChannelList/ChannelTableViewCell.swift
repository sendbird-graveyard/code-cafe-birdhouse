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
    
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var participantStackView: UIStackView!
    @IBOutlet weak var participantCountLabel: UILabel!
    
    // MARK: Configure Cell with Room information
    var room: Room? {
        didSet {
            guard let room = room else { return }
            room.participants.forEach { participant in
                if participantStackView.arrangedSubviews.count <= 4 {
                    let label = UILabel()
                    label.text = "✋ \(participant.user.nickname?.collapsed ?? participant.user.userId)"
                    label.font = UIFont(name: "Gellix-Medium", size: 15)
                    label.textAlignment = .right
                    label.sizeToFit()
                    participantStackView.addArrangedSubview(label)
                }
            }
            
            participantCountLabel.text = String(room.participants.count)
            channelTitleLabel.text = room.title
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        participantStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}
