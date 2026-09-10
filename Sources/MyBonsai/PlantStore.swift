import Foundation

/// Persisted plant state. Growth is derived from real elapsed time since
/// `plantedAt`, so the plant keeps trailing longer between launches.
/// Trimming lowers a strand's cap so it never regrows past a cut.
struct PlantState: Codable {
    var plantedAt: Date
    var strandCaps: [Int]      // max points per strand (reduced by trimming)
}

final class PlantStore {
    private(set) var state: PlantState
    private let url: URL

    /// Fully grown length (in points) for each strand at "plant a new one".
    static let baseLengths = [9, 13, 16, 12, 17, 13, 9, 20, 21]

    // One segment grows in roughly every few days in release; fast in debug.
    #if DEBUG
    static let growthInterval: TimeInterval = 3
    #else
    static let growthInterval: TimeInterval = 3 * 24 * 60 * 60
    #endif

    init() {
        let dir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MyBonsai", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        url = dir.appendingPathComponent("plant.json")

        if let data = try? Data(contentsOf: url),
           let saved = try? JSONDecoder().decode(PlantState.self, from: data) {
            state = saved
        } else {
            state = PlantState(plantedAt: Date(), strandCaps: Self.baseLengths)
        }
    }

    /// Target number of points strand `i` should have grown to by `date`,
    /// capped by any trimming.
    func target(_ i: Int, at date: Date) -> Int {
        let elapsed = max(0, date.timeIntervalSince(state.plantedAt))
        let byTime = 2 + Int(elapsed / Self.growthInterval)
        return min(state.strandCaps[i], byTime)
    }

    func trim(_ i: Int, to length: Int) {
        state.strandCaps[i] = max(1, length)
        save()
    }

    func replant() {
        state = PlantState(plantedAt: Date(), strandCaps: Self.baseLengths)
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(state) {
            try? data.write(to: url)
        }
    }
}
