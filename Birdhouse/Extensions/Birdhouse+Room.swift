//
//  Birdhouse+Room.swift
//  Birdhouse
//
//  Created by Minhyuk Kim on 2021/10/27.
//

import SendBirdCalls

extension Room {
    var title: String {
        get {
            return customItems["title"] ?? "Unnamed Room"
        }
        set {
            updateCustomItems(customItems: ["title": newValue]) { customItems, updatedKeys, error in
                print("Updated room title with error: \(String(describing: error))")
            }
        }
    }
}
