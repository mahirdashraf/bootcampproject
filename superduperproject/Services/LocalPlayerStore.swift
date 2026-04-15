import Foundation

final class LocalPlayerStore {
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    private let fileURL: URL

    // points the store at a simple json file in app support
    init(filename: String = "player.json") {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let dir = base ?? FileManager.default.temporaryDirectory
        self.fileURL = dir.appendingPathComponent(filename)
    }

    // reads player.json and decodes it into PlayerModel (or nil if missing)
    func load() throws -> PlayerModel? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(PlayerModel.self, from: data)
    }

    // encodes the player to player.json atomically
    func save(_ player: PlayerModel) throws {
        let dir = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let data = try encoder.encode(player)
        try data.write(to: fileURL, options: [.atomic])
    }
}

