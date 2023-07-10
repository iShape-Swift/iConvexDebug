//
//  PinVector.swift
//  iConvexDebug
//
//  Created by Nail Sharipov on 10.07.2023.
//

import SwiftUI
import iDebug

struct PinVector: Identifiable {
    
    var id: Int { arrow.id }
    let arrow: Arrow
    let title: String?
    let titlePos: CGPoint?
    
}


struct PinVectorView: View {
    
    let pin: PinVector
    
    var body: some View {
        ZStack() {
            ArrowView(arrow: pin.arrow)
            if let title = pin.title, let pos = pin.titlePos {
                Text(title).position(pos).foregroundColor(.black)
            }
        }
    }
}
