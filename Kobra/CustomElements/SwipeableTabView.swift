//
//  SwipeableTabView.swift
//  Kobra
//
//  Created by Spencer SLiffe on 4/2/23.
//

import Foundation
import SwiftUI

struct SwipeableTabView<Content: View>: View {
    @Binding var selectedTab: String
    let content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    content()
                        .frame(width: geometry.size.width)
                }
            }
            .content.offset(x: -CGFloat(getIndex()) * geometry.size.width)
            .frame(width: geometry.size.width, alignment: .leading)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        let offset = value.predictedEndTranslation.width / geometry.size.width
                        let newIndex = (CGFloat(getIndex()) - offset).rounded()
                        selectedTab = getIndex(from: Int(newIndex))
                    }
            )
        }
    }
    
    private func getIndex(from index: Int) -> String {
        switch index {
        case 0:
            return "account"
        case 1:
            return "inbox"
        case 2:
            return "home"
        case 3:
            return "market"
        case 4:
            return "package"
        default:
            return "home"
        }
    }
    
    private func getIndex() -> Int {
        switch selectedTab {
        case "account":
            return 0
        case "inbox":
            return 1
        case "home":
            return 2
        case "market":
            return 3
        case "package":
            return 4
        default:
            return 2
        }
    }
}
