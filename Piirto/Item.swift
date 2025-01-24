//
//  Item.swift
//  Piirto
//
//  Created by Miika Kuisma on 23.1.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
