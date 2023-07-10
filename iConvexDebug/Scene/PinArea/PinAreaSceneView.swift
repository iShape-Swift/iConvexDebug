//
//  PinAreaSceneView.swift
//  iConvexDebug
//
//  Created by Nail Sharipov on 10.07.2023.
//

import SwiftUI

struct PinAreaSceneView: View {
 
    @ObservedObject
    var scene: PinAreaScene
    
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
                    Text("Convex A").font(.title2).foregroundColor(PinAreaScene.colorA)
                    Text("Convex B").font(.title2).foregroundColor(PinAreaScene.colorB)
                }
                Spacer()
            }
            ForEach(scene.dots) { dot in
                PinDotView(dot: dot)
            }
            ForEach(scene.sections) { sec in
                Path { path in
                    path.addLines(sec.area)
                    path.closeSubpath()
                }.fill(sec.areaColor)
                Path { path in
                    path.addLines(sec.pathA)
                }.stroke(style: .init(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .foregroundColor(sec.color)
                Path { path in
                    path.addLines(sec.pathB)
                }.stroke(style: .init(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .foregroundColor(sec.color)
                Text(sec.areaValue).font(.title3).foregroundColor(.black).position(sec.areaCenter)
            }
            scene.editorAView()
            scene.editorBView()
        }.onAppear() {
            scene.onAppear()
        }
    }

}
