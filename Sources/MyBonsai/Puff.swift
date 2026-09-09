import CoreGraphics

/// A single foliage "puff". Positions live in a 220 x 300 design canvas
/// (origin top-left, y increasing downward) and are scaled to the window.
struct Puff: Identifiable {
    let id: Int
    let center: CGPoint     // in design space
    let radius: CGFloat     // base cluster radius in design space
    let limbFrom: CGPoint   // where its branch leaves the trunk

    static let canvasSize = CGSize(width: 220, height: 300)
    static let potBase = CGPoint(x: 110, y: 250)

    // Grow order = array order.
    static let all: [Puff] = [
        Puff(id: 0, center: CGPoint(x: 110, y: 78),  radius: 40, limbFrom: CGPoint(x: 106, y: 150)),
        Puff(id: 1, center: CGPoint(x: 70,  y: 150), radius: 34, limbFrom: CGPoint(x: 104, y: 178)),
        Puff(id: 2, center: CGPoint(x: 152, y: 146), radius: 36, limbFrom: CGPoint(x: 106, y: 172)),
        Puff(id: 3, center: CGPoint(x: 62,  y: 112), radius: 30, limbFrom: CGPoint(x: 102, y: 158)),
        Puff(id: 4, center: CGPoint(x: 160, y: 110), radius: 32, limbFrom: CGPoint(x: 106, y: 154)),
    ]

    /// The trunk as two bezier segments in design space:
    /// [start, c1, c2, mid, c3, c4, end]
    static func trunkPoints() -> [CGPoint] {
        [
            CGPoint(x: 110, y: 250),
            CGPoint(x: 103, y: 212), CGPoint(x: 122, y: 190), CGPoint(x: 104, y: 168),
            CGPoint(x: 92,  y: 150), CGPoint(x: 100, y: 130), CGPoint(x: 106, y: 108)
        ]
    }
}
