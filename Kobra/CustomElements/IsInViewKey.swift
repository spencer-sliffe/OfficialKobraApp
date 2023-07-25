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
        return frame.intersects(UIScreen.main.bounds)
    }
}
