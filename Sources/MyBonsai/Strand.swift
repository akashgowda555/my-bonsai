import CoreGraphics

/// One point in a verlet chain (position + previous position).
struct VPoint {
    var x: CGFloat, y: CGFloat
    var px: CGFloat, py: CGFloat
}

/// A single hanging strand of "pearls", simulated as a verlet rope.
/// SpriteKit's y axis points up, so gravity subtracts from y and strands
/// hang downward from their anchor on the pot rim.
final class Strand {
    let index: Int
    var anchor: CGPoint
    let lean: CGFloat
    var points: [VPoint]

    static let seg: CGFloat = 13
    static let gravity: CGFloat = 0.55
    static let damping: CGFloat = 0.985
    static let iterations = 3

    init(index: Int, anchor: CGPoint, lean: CGFloat) {
        self.index = index
        self.anchor = anchor
        self.lean = lean
        points = [
            VPoint(x: anchor.x, y: anchor.y, px: anchor.x, py: anchor.y),
            VPoint(x: anchor.x + lean * 3, y: anchor.y - Strand.seg, px: anchor.x, py: anchor.y)
        ]
    }

    /// Append points until the chain reaches `target` length.
    func grow(to target: Int) {
        while points.count < target {
            let tail = points[points.count - 1]
            points.append(VPoint(x: tail.x + lean, y: tail.y - 2, px: tail.x, py: tail.y))
        }
        if points.count > target { points.removeLast(points.count - target) }
    }

    /// One physics tick. `wind` is a shared horizontal breeze.
    func step(wind: CGFloat) {
        for i in 1..<points.count {
            var p = points[i]
            let vx = (p.x - p.px) * Strand.damping
            let vy = (p.y - p.py) * Strand.damping
            p.px = p.x; p.py = p.y
            p.x += vx + wind * (CGFloat(i) / CGFloat(points.count))
            p.y += vy - Strand.gravity
            points[i] = p
        }
        for _ in 0..<Strand.iterations {
            points[0].x = anchor.x; points[0].y = anchor.y
            for i in 1..<points.count {
                let a = points[i - 1], b = points[i]
                let dx = b.x - a.x, dy = b.y - a.y
                let d = max(0.001, (dx * dx + dy * dy).squareRoot())
                let diff = (d - Strand.seg) / d
                let mx = dx * 0.5 * diff, my = dy * 0.5 * diff
                if i > 1 { points[i - 1].x += mx; points[i - 1].y += my }
                points[i].x -= mx; points[i].y -= my
            }
        }
    }
}
