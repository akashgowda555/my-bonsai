import SpriteKit

/// Renders the hanging plant: a face pot with strands of pearls that dangle
/// (verlet physics), grow over time, bloom on a break, and can be trimmed by
/// clicking. Pure SpriteKit nodes; physics is the custom solver in Strand.
final class PlantScene: SKScene {
    private let store: PlantStore
    private var strands: [Strand] = []
    private var stems: [SKShapeNode] = []
    private var pearls: [[SKShapeNode]] = []
    private var flowers: [SKNode] = []
    private var lastTime: TimeInterval = 0
    private var windPhase = CGFloat.random(in: 0..<10)

    // Anchor offsets from the pot centre (x, y-drop below rim).
    private let anchorSpecs: [(CGFloat, CGFloat)] = [
        (-64, 10), (-42, 17), (-20, 20), (2, 14), (24, 20),
        (46, 15), (64, 9), (-14, 22), (16, 23)
    ]
    private var potCenter = CGPoint.zero
    private let greens: [SKColor] = [
        SKColor(red: 0.58, green: 0.76, blue: 0.46, alpha: 1),
        SKColor(red: 0.51, green: 0.71, blue: 0.40, alpha: 1),
        SKColor(red: 0.64, green: 0.82, blue: 0.53, alpha: 1),
        SKColor(red: 0.47, green: 0.67, blue: 0.36, alpha: 1)
    ]

    init(size: CGSize, store: PlantStore) {
        self.store = store
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    override func didMove(to view: SKView) {
        potCenter = CGPoint(x: size.width / 2, y: size.height - 150)
        buildPot()
        buildStrands()
    }

    // MARK: build

    private func buildPot() {
        let rx: CGFloat = 80, ry: CGFloat = 22, bh: CGFloat = 98
        let c = potCenter

        let body = SKShapeNode(path: potBodyPath(c: c, rx: rx, ry: ry, bh: bh))
        body.fillColor = SKColor(red: 0.957, green: 0.937, blue: 0.902, alpha: 1)
        body.strokeColor = .clear
        body.zPosition = 1
        addChild(body)

        // sleeping eyes
        let eyeY = c.y - 54
        for dx in [-19 as CGFloat, 19] {
            let eye = SKShapeNode(path: arcSmile(cx: c.x + dx, cy: eyeY, w: 22, h: 8))
            eye.strokeColor = SKColor(white: 0.22, alpha: 1)
            eye.lineWidth = 3; eye.lineCap = .round; eye.zPosition = 2
            addChild(eye)
        }
        // blush
        for dx in [-34 as CGFloat, 34] {
            let cheek = SKShapeNode(ellipseOf: CGSize(width: 18, height: 12))
            cheek.position = CGPoint(x: c.x + dx, y: c.y - 64)
            cheek.fillColor = SKColor(red: 0.96, green: 0.76, blue: 0.68, alpha: 0.55)
            cheek.strokeColor = .clear; cheek.zPosition = 2
            addChild(cheek)
        }
        // soil + crown mound
        let soil = SKShapeNode(ellipseOf: CGSize(width: (rx - 6) * 2, height: (ry - 4) * 2))
        soil.position = CGPoint(x: c.x, y: c.y)
        soil.fillColor = SKColor(red: 0.29, green: 0.21, blue: 0.14, alpha: 1)
        soil.strokeColor = .clear; soil.zPosition = 2
        addChild(soil)

        var seed: UInt64 = 999
        func rnd() -> CGFloat { seed = seed &* 6364136223846793005 &+ 1; return CGFloat((seed >> 33) & 0xFFFF) / 65535.0 }
        for i in 0..<30 {
            let a = rnd() * .pi * 2, rr = rnd()
            let x = c.x + cos(a) * rx * 0.82 * rr
            let y = c.y + 5 + sin(a) * ry * 0.7 * rr
            let r = 4.8 + rnd() * 1.8
            let dot = SKShapeNode(circleOfRadius: r)
            dot.position = CGPoint(x: x, y: y)
            dot.fillColor = greens[i % greens.count]; dot.strokeColor = .clear
            dot.zPosition = 3
            addChild(dot)
        }
    }

    private func buildStrands() {
        strands.removeAll(); stems.forEach { $0.removeFromParent() }
        pearls.flatMap { $0 }.forEach { $0.removeFromParent() }
        stems.removeAll(); pearls.removeAll()

        for (i, spec) in anchorSpecs.enumerated() {
            let ax = potCenter.x + spec.0
            let ay = potCenter.y - spec.1
            let lean: CGFloat = (spec.0 < 0 ? -1 : 1) * CGFloat.random(in: 0.4...0.9)
            strands.append(Strand(index: i, anchor: CGPoint(x: ax, y: ay), lean: lean))

            let stem = SKShapeNode()
            stem.strokeColor = SKColor(red: 0.44, green: 0.62, blue: 0.34, alpha: 0.9)
            stem.lineWidth = 2.2; stem.zPosition = 4
            addChild(stem); stems.append(stem)
            pearls.append([])
        }
    }

    // MARK: loop

    override func update(_ currentTime: TimeInterval) {
        let dt = lastTime == 0 ? 1.0 / 60 : min(0.05, currentTime - lastTime)
        lastTime = currentTime
        let now = Date()
        let wind = sin(CGFloat(currentTime) * 0.7 + windPhase) * 0.22
                 + sin(CGFloat(currentTime) * 1.9) * 0.08

        for (i, st) in strands.enumerated() {
            st.grow(to: store.target(i, at: now))
            st.step(wind: wind)
            syncStrand(i, st)
        }
        _ = dt
    }

    private func syncStrand(_ i: Int, _ st: Strand) {
        // stem path
        let path = CGMutablePath()
        if let first = st.points.first {
            path.move(to: CGPoint(x: first.x, y: first.y))
            for p in st.points.dropFirst() { path.addLine(to: CGPoint(x: p.x, y: p.y)) }
        }
        stems[i].path = path

        // pearl nodes (create/remove to match, then position)
        let needed = max(0, st.points.count - 1)
        while pearls[i].count < needed {
            let idx = pearls[i].count + 1
            let r = max(2.6, 5.6 * (1 - CGFloat(idx) / 20 * 0.4))
            let dot = SKShapeNode(circleOfRadius: r)
            dot.fillColor = greens[(i + idx) % greens.count]
            dot.strokeColor = .clear; dot.zPosition = 5
            addChild(dot); pearls[i].append(dot)
        }
        while pearls[i].count > needed {
            pearls[i].removeLast().removeFromParent()
        }
        for k in 0..<needed {
            let p = st.points[k + 1]
            pearls[i][k].position = CGPoint(x: p.x, y: p.y)
        }
    }

    // MARK: interactions

    func bloom() {
        let colors: [SKColor] = [
            SKColor(red: 0.965, green: 0.66, blue: 0.76, alpha: 1),
            SKColor(red: 0.97, green: 0.84, blue: 0.45, alpha: 1),
            .white
        ]
        var placed = 0
        for st in strands.shuffled() where st.points.count >= 4 {
            let idx = Int.random(in: 3..<st.points.count)
            let p = st.points[idx]
            let flower = makeFlower(color: colors.randomElement()!)
            flower.position = CGPoint(x: p.x, y: p.y)
            flower.setScale(0.01); flower.zPosition = 6
            addChild(flower); flowers.append(flower)
            flower.run(.sequence([
                .scale(to: 1, duration: 0.4),
                .wait(forDuration: 8),
                .fadeOut(withDuration: 1),
                .removeFromParent()
            ]))
            placed += 1
            if placed >= 7 { break }
        }
    }

    private func makeFlower(color: SKColor) -> SKNode {
        let node = SKNode()
        let R: CGFloat = 7
        for k in 0..<5 {
            let a = CGFloat(k) / 5 * .pi * 2
            let petal = SKShapeNode(ellipseOf: CGSize(width: R * 1.4, height: R * 0.84))
            petal.position = CGPoint(x: cos(a) * R, y: sin(a) * R)
            petal.zRotation = a
            petal.fillColor = color; petal.strokeColor = .clear
            node.addChild(petal)
        }
        let core = SKShapeNode(circleOfRadius: R * 0.5)
        core.fillColor = SKColor(red: 0.96, green: 0.71, blue: 0, alpha: 1)
        core.strokeColor = .clear
        node.addChild(core)
        return node
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        let p = event.location(in: self)
        var best: (si: Int, i: Int)? = nil
        var bestD: CGFloat = 22
        for st in strands {
            for i in 1..<st.points.count {
                let d = hypot(st.points[i].x - p.x, st.points[i].y - p.y)
                if d < bestD { bestD = d; best = (st.index, i) }
            }
        }
        if let b = best { trim(b.si, b.i) }
    }
    #endif

    private func trim(_ si: Int, _ idx: Int) {
        let st = strands[si]
        guard idx < st.points.count else { return }
        // spawn a few falling pearls
        for k in idx..<st.points.count {
            let p = st.points[k]
            let dot = SKShapeNode(circleOfRadius: 4.4)
            dot.position = CGPoint(x: p.x, y: p.y)
            dot.fillColor = greens[(si + k) % greens.count]; dot.strokeColor = .clear
            dot.zPosition = 5
            addChild(dot)
            let dx = CGFloat.random(in: -18...18)
            dot.run(.sequence([
                .group([ .moveBy(x: dx, y: -220, duration: 1.1), .fadeOut(withDuration: 1.1) ]),
                .removeFromParent()
            ]))
        }
        st.points.removeLast(max(0, st.points.count - idx))
        store.trim(si, to: idx)
    }

    func replant() {
        store.replant()
        removeAllChildren()
        flowers.removeAll(); stems.removeAll(); pearls.removeAll()
        buildPot(); buildStrands()
    }

    // MARK: paths

    private func potBodyPath(c: CGPoint, rx: CGFloat, ry: CGFloat, bh: CGFloat) -> CGPath {
        let p = CGMutablePath()
        p.move(to: CGPoint(x: c.x - rx, y: c.y))
        p.addCurve(to: CGPoint(x: c.x, y: c.y - bh),
                   control1: CGPoint(x: c.x - rx, y: c.y - bh * 0.72),
                   control2: CGPoint(x: c.x - rx * 0.5, y: c.y - bh))
        p.addCurve(to: CGPoint(x: c.x + rx, y: c.y),
                   control1: CGPoint(x: c.x + rx * 0.5, y: c.y - bh),
                   control2: CGPoint(x: c.x + rx, y: c.y - bh * 0.72))
        p.closeSubpath()
        return p
    }

    private func arcSmile(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> CGPath {
        let p = CGMutablePath()
        p.move(to: CGPoint(x: cx - w / 2, y: cy))
        p.addQuadCurve(to: CGPoint(x: cx + w / 2, y: cy),
                       control: CGPoint(x: cx, y: cy - h))
        return p
    }
}
