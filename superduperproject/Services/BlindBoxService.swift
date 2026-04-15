import Foundation

struct BlindBoxService {
    // rolls one item from a pool using cumulative weights
    func rollItem(from pool: [ItemModel], perDropWeights: [String: Double]? = nil) -> ItemModel? {
        guard !pool.isEmpty else { return nil }

        let weights: [Double] = pool.map { item in
            if let w = perDropWeights?[item.id] { return max(0, w) }
            return item.weight ?? item.rarity.dropWeight
        }

        let total = weights.reduce(0, +)
        guard total > 0 else { return pool.randomElement() }

        var r = Double.random(in: 0..<total)
        for (idx, w) in weights.enumerated() {
            r -= w
            if r < 0 {
                return pool[idx]
            }
        }

        return pool.last
    }
}

