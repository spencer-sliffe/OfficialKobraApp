//
//  PriceFormatter.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/17/24.
//

import Foundation
import SwiftUI

struct TimestampView: View {
    let timestamp: Date
    
    var body: some View {
        Text(timestamp.formatted())
            .font(.caption)
            .foregroundColor(.white)
    }
}
