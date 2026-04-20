import Foundation
import FirebaseFirestore

struct InventoryEntry: Codable, Hashable {
    var itemID: String
    var duplicateCount: Int
}

struct PlayerModel: Identifiable, Codable, Hashable {
    @DocumentID var id: String?

    var displayName: String?

    var totalMoney: Double
    var moneyPerSecond: Double
    var lastSavedDate: Date

    var inventory: [InventoryEntry]
    var unlockedWorlds: [Universe]
    var boxesOpened: Int
}
