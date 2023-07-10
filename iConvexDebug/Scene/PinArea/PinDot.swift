//
//  PinDot.swift
//  iConvexDebug
//
//  Created by Nail Sharipov on 10.07.2023.
//

import SwiftUI
import iDebug

struct PinDot: Identifiable {
    
    public let id: Int
    public let center: CGPoint
    public let color: Color
    public let title: String?
    
}


struct PinDotView: View {
    
    let dot: PinDot
    
    var body: some View {
        ZStack() {
            CircleView(position: dot.center, radius: 4, color: dot.color)
            if let title = dot.title {
                Text(title).position(dot.center + CGPoint(x: -2, y: -10)).foregroundColor(.red)
            }
        }
    }
}
