import SwiftUI

/// The whole tree, drawn in a fixed design canvas then scaled to the window.
struct BonsaiView: View {
    @ObservedObject var store: BonsaiStore

    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date
            let t = now.timeIntervalSinceReferenceDate
            let sway = sin(t * 0.6) * 1.2 + sin(t * 1.31) * 0.4   // degrees
            let grown = store.grownCount(at: now)

            GeometryReader { geo in
                let s = min(geo.size.width / Puff.canvasSize.width,
                            geo.size.height / Puff.canvasSize.height)

                ZStack(alignment: .topLeading) {
                    WoodAndPot(grownCount: grown)
                        .frame(width: Puff.canvasSize.width, height: Puff.canvasSize.height)

                    ForEach(Array(Puff.all.prefix(grown))) { puff in
                        if !store.state.prunedPuffIDs.contains(puff.id) {
                            PuffView(radius: puff.radius)
                                .position(puff.center)
                                .contentShape(Circle())
                                .onTapGesture {
                                    if store.isGrooming { store.prune(puff.id) }
                                }
                        }
                    }
                }
                .frame(width: Puff.canvasSize.width, height: Puff.canvasSize.height)
                .scaleEffect(s, anchor: .topLeading)
                .rotationEffect(.degrees(sway), anchor: UnitPoint(x: 0.5, y: 0.83))
            }
        }
    }
}

/// Pot, soil, trunk and the limbs of whatever has grown so far.
private struct WoodAndPot: View {
    let grownCount: Int

    private let bark = Color(red: 0.61, green: 0.42, blue: 0.25)

    var body: some View {
        Canvas { ctx, _ in
            // ground shadow
            let shadow = Path(ellipseIn: CGRect(x: 30, y: 246, width: 160, height: 22))
            ctx.fill(shadow, with: .color(Color(red: 0.76, green: 0.80, blue: 0.71).opacity(0.5)))

            // pot
            var pot = Path()
            pot.move(to: CGPoint(x: 66, y: 248))
            pot.addLine(to: CGPoint(x: 154, y: 248))
            pot.addLine(to: CGPoint(x: 144, y: 286))
            pot.addQuadCurve(to: CGPoint(x: 76, y: 286), control: CGPoint(x: 110, y: 294))
            pot.closeSubpath()
            ctx.fill(pot, with: .linearGradient(
                Gradient(colors: [Color(red: 0.88, green: 0.58, blue: 0.43),
                                  Color(red: 0.75, green: 0.42, blue: 0.27)]),
                startPoint: CGPoint(x: 110, y: 248), endPoint: CGPoint(x: 110, y: 286)))

            // soil
            ctx.fill(Path(ellipseIn: CGRect(x: 62, y: 242, width: 96, height: 12)),
                     with: .color(Color(red: 0.24, green: 0.17, blue: 0.12)))

            // trunk
            let p = Puff.trunkPoints()
            var trunk = Path()
            trunk.move(to: p[0])
            trunk.addCurve(to: p[3], control1: p[1], control2: p[2])
            trunk.addCurve(to: p[6], control1: p[4], control2: p[5])
            ctx.stroke(trunk, with: .color(bark),
                       style: StrokeStyle(lineWidth: 13, lineCap: .round))

            // limbs to grown puffs
            for puff in Puff.all.prefix(grownCount) {
                var limb = Path()
                limb.move(to: puff.limbFrom)
                limb.addQuadCurve(
                    to: puff.center,
                    control: CGPoint(x: (puff.limbFrom.x + puff.center.x) / 2,
                                     y: min(puff.limbFrom.y, puff.center.y) - 6))
                ctx.stroke(limb, with: .color(bark),
                           style: StrokeStyle(lineWidth: 6, lineCap: .round))
            }
        }
    }
}

/// A soft cluster of overlapping circles that reads as a leafy puff.
private struct PuffView: View {
    let radius: CGFloat

    private let blobs: [(CGPoint, CGFloat)] = [
        (CGPoint(x: -14, y: 2),  26), (CGPoint(x: 16, y: 4), 24),
        (CGPoint(x: 0,  y: -6), 28), (CGPoint(x: -24, y: 6), 18),
        (CGPoint(x: 26, y: 7),  17)
    ]
    private let highlights: [(CGPoint, CGFloat)] = [
        (CGPoint(x: -6, y: -12), 15), (CGPoint(x: 8, y: -8), 12)
    ]

    var body: some View {
        let k = radius / 30.0
        ZStack {
            Circle().fill(Color(red: 0.31, green: 0.54, blue: 0.29))
                .frame(width: 60 * k, height: 40 * k)
                .offset(x: 2 * k, y: 9 * k)
            ForEach(0..<blobs.count, id: \.self) { i in
                Circle()
                    .fill(RadialGradient(
                        colors: [Color(red: 0.75, green: 0.89, blue: 0.63),
                                 Color(red: 0.56, green: 0.77, blue: 0.45),
                                 Color(red: 0.37, green: 0.60, blue: 0.33)],
                        center: .topLeading, startRadius: 1, endRadius: 40 * k))
                    .frame(width: blobs[i].1 * 2 * k, height: blobs[i].1 * 2 * k)
                    .offset(x: blobs[i].0.x * k, y: blobs[i].0.y * k)
            }
            ForEach(0..<highlights.count, id: \.self) { i in
                Circle().fill(Color(red: 0.76, green: 0.90, blue: 0.64).opacity(0.7))
                    .frame(width: highlights[i].1 * 2 * k, height: highlights[i].1 * 2 * k)
                    .offset(x: highlights[i].0.x * k, y: highlights[i].0.y * k)
            }
        }
    }
}
