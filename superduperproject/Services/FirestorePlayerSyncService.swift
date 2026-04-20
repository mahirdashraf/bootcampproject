//
//  FirestorePlayerSyncService.swift
//  superduperproject
//
//  Created by Juliana Martinez on 4/19/26.
//

import Foundation
import FirebaseFirestore

struct FirestorePlayerSyncService: PlayerSyncServiceProtocol {
    
    private let db = Firestore.firestore()
    
    func loadPlayer(userID: String) async throws -> PlayerModel? {
        let doc = try await db.collection("users")
            .document(userID)
            .getDocument()
        
        return try doc.data(as: PlayerModel.self)
    }
    
    func savePlayer(_ player: PlayerModel) async throws {
        guard let id = player.id else { return }
        
        let encoder = Firestore.Encoder()
        let data = try encoder.encode(player)
        
        try await db.collection("users")
            .document(id)
            .setData(data, merge: true)
    }
}
