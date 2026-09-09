import Foundation

/// Persisted state for the tree. Growth is derived from real elapsed time
/// since `plantedAt`, so the bonsai keeps growing between launches.
struct BonsaiState: Codable {
    var plantedAt: Date
    var prunedPuffIDs: Set<Int>

    static func fresh() -> BonsaiState {
        BonsaiState(plantedAt: Date(), prunedPuffIDs: [])
    }
}

final class BonsaiStore: ObservableObject {
    @Published private(set) var state: BonsaiState
    @Published var isGrooming: Bool = false

    // Roughly one new puff a week in release; fast in debug for testing.
    #if DEBUG
    static let growthInterval: TimeInterval = 5
    #else
    static let growthInterval: TimeInterval = 7 * 24 * 60 * 60
    #endif

    private let url: URL

    init() {
        let dir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MyBonsai", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        url = dir.appendingPathComponent("state.json")

        if let data = try? Data(contentsOf: url),
           let saved = try? JSONDecoder().decode(BonsaiState.self, from: data) {
            state = saved
        } else {
            state = .fresh()
        }
    }

    /// How many foliage puffs have grown in by `date`. Starts at 1 so a
    /// freshly planted tree is never completely bare.
    func grownCount(at date: Date) -> Int {
        let elapsed = date.timeIntervalSince(state.plantedAt)
        let byTime = 1 + Int(max(0, elapsed) / Self.growthInterval)
        return min(Puff.all.count, byTime)
    }

    func prune(_ id: Int) {
        guard !state.prunedPuffIDs.contains(id) else { return }
        state.prunedPuffIDs.insert(id)
        save()
    }

    func replant() {
        state = .fresh()
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(state) {
            try? data.write(to: url)
        }
    }
}
