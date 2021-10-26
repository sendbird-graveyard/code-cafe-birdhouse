//
//  Birdhouse+UIView.swift
//  Birdhouse
//
//  Created by Minhyuk Kim on 2021/10/25.
//

import UIKit

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            if newValue > 0 {
                clipsToBounds = true
            }
        }
    }
}
