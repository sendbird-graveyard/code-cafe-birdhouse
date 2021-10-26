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
//    var channel: SBDGroupChannel!
    
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
//        let vc = SBUChannelViewController(channelUrl: channel.channelUrl)
//        self.present(vc, animated: true, completion: nil)
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
            sender.setImage(.init(systemName: "mic.slash.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        } else {
            room.localParticipant?.unmuteMicrophone()
            sender.setImage(.init(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        }
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: localParticipantIndex)
        }
    }
    
    @IBAction func showChat(_ sender: Any) {
        let viewController = SBUChannelViewController(channelUrl: room.roomId, messageListParams: nil)
        self.present(viewController, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "participant", for: indexPath) as? ParticipantCell else { return UICollectionViewCell() }
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
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//           return 5
//       }
//
//       // 옆 간격
//       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//           return 5
//       }
//
//
//
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let width = collectionView.frame.width / 4 - 5 ///  3등분하여 배치, 옆 간격이 1이므로 1을 빼줌
//        print("collectionView width=\(collectionView.frame.width)")
//        print("cell하나당 width=\(width)")
//        print("root view width = \(self.view.frame.width)")
//
//        let size = CGSize(width: width, height: width)
//        return size
////        switch room.participants.count {
////        case ...1:
////            let width = UIScreen.main.bounds.width - 8
////            let height = 4/3 * width
////            return CGSize(width: width, height: height)
////        case 2...4:
////            let width = (UIScreen.main.bounds.width - 8)/2
////            let height = 4/3 * width
////            return CGSize(width: width, height: height)
////        default:
////            let height = (collectionView.bounds.height - 8) / 3
////            let width = 3/4 * height
////            return CGSize(width: width, height: height)
////        }
//    }
}

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
    
    func updateView(with participant: Participant) {
        userIdLabel.text = "\(participant.user.nickname?.collapsed ?? participant.user.userId)"
        audioMutedImageView.isHidden = participant.isAudioEnabled

        profileImageView.updateImage(urlString: participant.user.profileURL)
    }
}

extension ParticipantCell: RoomDelegate {
    func didRemoteAudioSettingsChange(_ participant: RemoteParticipant) {
        guard participant.participantId == self.participant?.participantId else { return }
        
        updateView(with: participant)
    }
}



class FlowLayout: UICollectionViewFlowLayout {
    required init(itemSize: CGSize, minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 0, sectionInset: UIEdgeInsets = .zero) {
        super.init()
        
        self.itemSize = itemSize
        self.minimumInteritemSpacing = 4
        self.minimumLineSpacing = 4
        self.sectionInset = sectionInset
        sectionInsetReference = .fromSafeArea
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sectionInsetReference = .fromSafeArea
        self.minimumInteritemSpacing = 4
        self.minimumLineSpacing = 4
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)?.compactMap { $0.copy() as? UICollectionViewLayoutAttributes } ?? []
        guard scrollDirection == .vertical else { return layoutAttributes }
        
        let cellAttributes = layoutAttributes.filter({ $0.representedElementCategory == .cell })
        
        // Group cell attributes by row (cells with same vertical center) and loop on those groups
        for (_, attributes) in Dictionary(grouping: cellAttributes, by: { ($0.center.y / 10).rounded(.up) * 10 }) {
            // Get the total width of the cells on the same row
            let cellsTotalWidth = attributes.reduce(CGFloat(0)) { (partialWidth, attribute) -> CGFloat in
                partialWidth + attribute.size.width
            }
            
            // Calculate the initial left inset
            let totalInset = collectionView!.safeAreaLayoutGuide.layoutFrame.width - cellsTotalWidth - sectionInset.left - sectionInset.right - minimumInteritemSpacing * CGFloat(attributes.count - 1)
            var leftInset = (totalInset / 2 * 10).rounded(.down) / 10 + sectionInset.left
            
            // Loop on cells to adjust each cell's origin and prepare leftInset for the next cell
            for attribute in attributes {
                attribute.frame.origin.x = leftInset
                leftInset = attribute.frame.maxX + minimumInteritemSpacing
            }
        }
        return layoutAttributes
    }
}
