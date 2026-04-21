//
//  FirestorePlayerSyncService.swift
//  superduperproject
//
//  Created by Juliana Martinez on 4/19/26.
//

import FirebaseFirestore

struct FirestorePlayerSyncService: PlayerSyncServiceProtocol {

    private let db = Firestore.firestore()

    func loadPlayer(userID: String) async throws -> PlayerModel? {
        let doc = try await db.collection("users")
            .document(userID)
            .getDocument()
        guard doc.exists else { return nil }
        return try doc.data(as: PlayerModel.self)
    }

    func savePlayer(_ player: PlayerModel) async throws {
        guard let userID = player.id else {
            print("Cannot save player: missing userID")
            return
        }
        do {
            try db.collection("users")
                .document(userID)
                .setData(from: player, merge: true)
            print("Player saved to Firestore")
        } catch {
            print("Firestore save failed:", error)
            throw error
        }
    }
}
