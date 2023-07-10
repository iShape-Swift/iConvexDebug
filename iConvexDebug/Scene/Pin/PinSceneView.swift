//
//  PinSceneView.swift
//  iConvexDebug
//
//  Created by Nail Sharipov on 10.07.2023.
//

import SwiftUI

struct PinSceneView: View {
 
    @ObservedObject
    var scene: PinScene
    
    var body: some View {
        return HStack {
            GeometryReader { proxy in
                content(size: proxy.size)
            }
        }
    }
    
    private func content(size: CGSize) -> some View {
        scene.initSize(screenSize: size)
        return ZStack {
            Color.white
            VStack {
                Button("Print Test") {
                    scene.printTest()
                }.buttonStyle(.borderedProminent).padding()
                Button("Solve") {
                    scene.solve()
                }.buttonStyle(.borderedProminent).padding()
                HStack {
                    Text("Convex A").font(.title2).foregroundColor(PinScene.colorA)
                    Text("Convex B").font(.title2).foregroundColor(PinScene.colorB)
                }
                Spacer()
            }
            scene.editorAView()
            scene.editorBView()
            ForEach(scene.pins) { pin in
                PinVectorView(pin: pin)
            }
        }.onAppear() {
            scene.onAppear()
        }
    }

}
