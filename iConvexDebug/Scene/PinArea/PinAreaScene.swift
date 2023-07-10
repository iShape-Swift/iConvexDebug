//
//  PinAreaScene.swift
//  iConvexDebug
//
//  Created by Nail Sharipov on 10.07.2023.
//

import SwiftUI
import iDebug
import iConvex
import iFixFloat

struct Section: Identifiable {
    
    let id: Int
    let color: Color
    let areaColor: Color
    let areaCenter: CGPoint
    let areaValue: String
    let pathA: [CGPoint]
    let pathB: [CGPoint]
    let area: [CGPoint]
}

final class PinAreaScene: ObservableObject, SceneContainer {

    static let colorA: Color = .red
    static let colorB: Color = .blue
    
    let id: Int
    let title = "PinArea"
    let pinTestStore = PinTestStore()
    var testStore: TestStore { pinTestStore }
    let editorA = ContourEditor(showIndex: true, color: PinAreaScene.colorA)
    let editorB = ContourEditor(showIndex: true, color: PinAreaScene.colorB)
    
    var dots: [PinDot] = []
    var sections: [Section] = []
    
    private var matrix: Matrix = .empty
    
    init(id: Int) {
        self.id = id
        pinTestStore.onUpdate = self.didUpdateTest
        
        editorA.onUpdate = { [weak self] _ in
            self?.didUpdateEditor()
        }
        editorB.onUpdate = { [weak self] _ in
            self?.didUpdateEditor()
        }
    }
    
    func initSize(screenSize: CGSize) {
        if !matrix.screenSize.isIntSame(screenSize) {
            matrix = Matrix(screenSize: screenSize, scale: 10, inverseY: true)
            DispatchQueue.main.async { [weak self] in
                self?.solve()
            }
        }
    }
    
    func makeView() -> PinAreaSceneView {
        PinAreaSceneView(scene: self)
    }

    func editorAView() -> ContourEditorView {
        editorA.makeView(matrix: matrix)
    }
    
    func editorBView() -> ContourEditorView {
        editorB.makeView(matrix: matrix)
    }
    
    func didUpdateTest() {
        let test = pinTestStore.test
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // TODO validate convex
            self.editorA.set(points: test.pA)
            self.editorB.set(points: test.pB)
            self.solve()
        }
    }
    
    func didUpdateEditor() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // TODO validate convex
            self.solve()
        }
    }
    
    func onAppear() {
        didUpdateTest()
    }

    func solve() {
        let pA = editorA.points.map({ $0.fixVec })
        let pB = editorB.points.map({ $0.fixVec })

        guard !pA.isEmpty && !pB.isEmpty else { return }
        
        
        let ctA = pA.isConvex
        let ctB = pB.isConvex

        editorA.set(stroke: 1, color: color(convexTest: ctA, main: PinAreaScene.colorA))
        editorB.set(stroke: 1, color: color(convexTest: ctB, main: PinAreaScene.colorB))
        
        guard ctA == .convex && ctB == .convex else { return }
        
        let pins = CrossSolver.intersect(pathA: pA, pathB: pB)
        
        dots.removeAll()
        for i in 0..<pins.count {
            let pin = pins[i]
            let center = matrix.screen(worldPoint: pin.p.point)
            dots.append(.init(id: i, center: center, color: .red, title: "Pin \(i)"))
        }
        
        let secs = OverlaySolver.debugIntersect(a: pA, b: pB)
        
        self.sections.removeAll()
        
        for i in 0..<secs.count {
            let sec = secs[i]
            
            if sec.unsafeArea == 0 {
                continue
            }
            
            let areaColor: Color = sec.unsafeArea > 0 ? .red.opacity(0.4) : .blue.opacity(0.4)
            
            let aPath = sec.a.map({ $0.point })
            let bPath = sec.b.map({ $0.point })
            
            var area: [CGPoint] = aPath
            area.removeFirst()
            area.removeLast()
            
            area.append(contentsOf: bPath.reversed())
            
            let areaCenter = area.reduce(CGPoint.zero, { $0 + $1 }) / CGFloat(area.count)

            let color = Color(index: i)
            sections.append(.init(
                id: i,
                color: color,
                areaColor: areaColor,
                areaCenter: matrix.screen(worldPoint: areaCenter),
                areaValue: String(sec.unsafeArea),
                pathA: matrix.screen(worldPoints: aPath),
                pathB: matrix.screen(worldPoints: bPath),
                area: matrix.screen(worldPoints: area)
            ))
        }
        
        self.objectWillChange.send()
    }
    
    private func color(convexTest: ConvexTest, main: Color) -> Color {
        switch convexTest {
        case .convex:
            return main
        case .nonConvex:
            return .red
        case .degenerate:
            return .orange
        }
    }
    
    func printTest() {
        print("A: \(editorA.points.prettyPrint())")
        print("B: \(editorB.points.prettyPrint())")
    }
    
}
