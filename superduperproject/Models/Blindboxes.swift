import Foundation

struct BlindBoxModel: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var universe: Universe
    var cost: Double

    var possibleDropItemIDs: [String]
    var perDropWeights: [String: Double]?

    var boxImageName: String
}
