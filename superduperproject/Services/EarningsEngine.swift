import Foundation

struct EarningsEngine {
    struct Config {
        var duplicateBonusRate: Double = 0.10
    }

    var config: Config = Config()

    // computes how much this one item earns per second with dupes applied
    func earningRate(for item: ItemModel, duplicateCount: Int) -> Double {
        let dupes = max(0, duplicateCount)
        return item.baseEarningRate * (1 + (config.duplicateBonusRate * Double(dupes)))
    }

    // sums all item earning rates into one moneyPerSecond number
    func moneyPerSecond(inventory: [InventoryEntry], itemLookup: (String) -> ItemModel?) -> Double {
        inventory.reduce(0) { partial, entry in
            guard let item = itemLookup(entry.itemID) else { return partial }
            return partial + earningRate(for: item, duplicateCount: entry.duplicateCount)
        }
    }
}

