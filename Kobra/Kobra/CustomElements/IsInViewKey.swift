//
//  IsInViewKey.swift
//  Kobra
//
//  Created by Spencer SLiffe on 7/25/23.
//

import Foundation
import SwiftUI

struct IsInViewKey: PreferenceKey {
    typealias Value = Bool

    static var defaultValue = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

extension View {
    func isInView(perform action: @escaping (Bool) -> Void) -> some View {
        return background(GeometryReader { geometryProxy in
            Color.clear.preference(key: IsInViewKey.self, value: geometryProxy.isInView)
        })
        .onPreferenceChange(IsInViewKey.self, perform: action)
    }
}

extension GeometryProxy {
    var isInView: Bool {
        let frame = self.frame(in: .global)
        let screenHeight = UIScreen.main.bounds.height

        // Define the top and bottom margins as percentages of the screen height
        let topMargin = screenHeight * 0.10
        let bottomMargin = screenHeight * 0.20

        // Calculate the area that should be considered as in view
        let visibleRect = CGRect(x: frame.origin.x,
                                 y: frame.origin.y + topMargin,
                                 width: frame.size.width,
                                 height: frame.size.height - (topMargin + bottomMargin))

        return visibleRect.intersects(UIScreen.main.bounds)
    }
}

