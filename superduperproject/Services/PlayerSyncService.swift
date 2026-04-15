import Foundation

protocol PlayerSyncServiceProtocol {
    // loads the player from cloud (return nil if missing)
    func loadPlayer(userID: String) async throws -> PlayerModel?

    // saves the full player to cloud
    func savePlayer(_ player: PlayerModel) async throws
}

struct NoopPlayerSyncService: PlayerSyncServiceProtocol {
    func loadPlayer(userID: String) async throws -> PlayerModel? { nil }
    func savePlayer(_ player: PlayerModel) async throws {}
}

