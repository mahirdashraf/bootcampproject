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
    var equippedCharacters: [String] = []
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case totalMoney
        case moneyPerSecond
        case lastSavedDate
        case inventory
        case unlockedWorlds
        case boxesOpened
        case equippedCharacters
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id = try container.decode(DocumentID<String>.self, forKey: .id)
        self.displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
        self.totalMoney = try container.decode(Double.self, forKey: .totalMoney)
        self.moneyPerSecond = try container.decode(Double.self, forKey: .moneyPerSecond)
        self.lastSavedDate = try container.decode(Date.self, forKey: .lastSavedDate)
        self.inventory = try container.decode([InventoryEntry].self, forKey: .inventory)
        self.unlockedWorlds = try container.decode([Universe].self, forKey: .unlockedWorlds)
        self.boxesOpened = try container.decode(Int.self, forKey: .boxesOpened)
        self.equippedCharacters = try container.decodeIfPresent([String].self, forKey: .equippedCharacters) ?? []
    }
    
    init(id: String?, displayName: String?, totalMoney: Double, moneyPerSecond: Double, lastSavedDate: Date, inventory: [InventoryEntry], unlockedWorlds: [Universe], boxesOpened: Int, equippedCharacters: [String] = []) {
        self.id = id
        self.displayName = displayName
        self.totalMoney = totalMoney
        self.moneyPerSecond = moneyPerSecond
        self.lastSavedDate = lastSavedDate
        self.inventory = inventory
        self.unlockedWorlds = unlockedWorlds
        self.boxesOpened = boxesOpened
        self.equippedCharacters = equippedCharacters
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(displayName, forKey: .displayName)
        try container.encode(totalMoney, forKey: .totalMoney)
        try container.encode(moneyPerSecond, forKey: .moneyPerSecond)
        try container.encode(lastSavedDate, forKey: .lastSavedDate)
        try container.encode(inventory, forKey: .inventory)
        try container.encode(unlockedWorlds, forKey: .unlockedWorlds)
        try container.encode(boxesOpened, forKey: .boxesOpened)
        try container.encode(equippedCharacters, forKey: .equippedCharacters)
    }
}
