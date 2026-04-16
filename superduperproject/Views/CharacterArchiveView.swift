//
//  CharacterArchiveView.swift
//  superduperproject
//
//  Created by Ashley Ni on 4/16/26.
//

import SwiftUI

struct CharacterArchiveView: View {
    @ObservedObject var userViewModel: UserViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedCharacterId: String?
    
    private var ownedCharacterIds: Set<String> {
        Set(userViewModel.player.inventory.map { $0.itemID })
    }
    
    private func getCharacterCount(_ itemId: String) -> Int {
        if let entry = userViewModel.player.inventory.first(where: { $0.itemID == itemId }) {
            return entry.duplicateCount + 1
        }
        return 0
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("CHARACTER ARCHIVES")
                    .font(.custom("PressStart2P-Regular", size: 20))
                    .foregroundColor(.white)
                    .padding()

                if let selectedId = selectedCharacterId,
                   let character = GameCatalog.itemCatalog[selectedId] {
                    VStack(spacing: 15) {
                        Image(character.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                            .frame(height: 125)
                            .padding()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("NAME: \(character.name.uppercased())")
                                .font(.custom("PressStart2P-Regular", size: 12))
                                .foregroundColor(.white)
                            
                            Text("VERSE: \(character.universe.rawValue.uppercased())")
                                .font(.custom("PressStart2P-Regular", size: 12))
                                .foregroundColor(.white)
                            
                            Text("RARITY: \(character.rarity.rawValue.uppercased())")
                                .font(.custom("PressStart2P-Regular", size: 12))
                                .foregroundColor(.white)
                            
                            Text("MPS: $\(String(format: "%.1f", character.baseEarningRate))")
                                .font(.custom("PressStart2P-Regular", size: 12))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                    .padding()
                } else {
                    Text("SELECT A CHARACTER")
                        .font(.custom("PressStart2P-Regular", size: 14))
                        .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.6))
                        .padding()
                }
                
                Spacer()
                
                VStack(spacing: 10) {
                    Text("ALL CHARACTERS")
                        .font(.custom("PressStart2P-Regular", size: 12))
                        .foregroundColor(.white)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(GameCatalog.itemCatalog.sorted(by: { $0.key < $1.key }), id: \.key) { itemId, character in
                                let isOwned = ownedCharacterIds.contains(itemId)
                                let count = getCharacterCount(itemId)
                                
                                VStack(spacing: 5) {
                                    Button(action: {
                                        selectedCharacterId = itemId
                                    }) {
                                        ZStack {
                                            Image(character.imageName)
                                                .resizable()
                                                .scaledToFit()
                                                .opacity(isOwned ? 1.0 : 0.4)
                                        }
                                        .frame(width: 120, height: 120)
                                        .background(selectedCharacterId == itemId ? Color(red: 0.6, green: 1.0, blue: 0.6) : Color.black.opacity(0.5))
                                        .border(selectedCharacterId == itemId ? Color(red: 0.6, green: 1.0, blue: 0.6) : Color.gray, width: 2)
                                        .cornerRadius(4)
                                    }
                                    
                                    if isOwned {
                                        Text("×\(count)")
                                            .font(.custom("PressStart2P-Regular", size: 10))
                                            .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.6))
                                    } else {
                                        Text("NOT OWNED")
                                            .font(.custom("PressStart2P-Regular", size: 8))
                                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.6))
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                }
                .padding()
                
                Button(action: {
                    dismiss()
                }) {
                    Text("BACK")
                        .font(.custom("PressStart2P-Regular", size: 14))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 1.0, green: 0.6, blue: 0.6))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CharacterArchiveView(userViewModel: UserViewModel())
}
