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
    @State private var showSwapOverlay = false
    @State private var characterToEquip: String?
    
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
                        
                        if ownedCharacterIds.contains(selectedId) {
                            if userViewModel.player.equippedCharacters.contains(selectedId) {
                                Button(action: {
                                    userViewModel.unequipCharacter(selectedId)
                                }) {
                                    Text("UNEQUIP")
                                        .font(.custom("PressStart2P-Regular", size: 12))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 35)
                                        .background(Color.red.opacity(0.8))
                                        .foregroundColor(.white)
                                        .cornerRadius(4)
                                }
                                .padding(.horizontal)
                            } else {
                                Button(action: {
                                    if userViewModel.player.equippedCharacters.count >= 3 {
                                        characterToEquip = selectedId
                                        showSwapOverlay = true
                                    } else {
                                        userViewModel.equipCharacter(selectedId)
                                    }
                                }) {
                                    Text("EQUIP")
                                        .font(.custom("PressStart2P-Regular", size: 12))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 35)
                                        .background(Color(red: 0.6, green: 1.0, blue: 0.6))
                                        .foregroundColor(.black)
                                        .cornerRadius(4)
                                }
                                .padding(.horizontal)
                            }
                        }
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
        .overlay(
            Group {
                if showSwapOverlay {
                    ZStack {
                        Color.black.opacity(0.85)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            Text("YOU CAN ONLY EQUIP 3 CHARACTERS.")
                                .font(.custom("PressStart2P-Regular", size: 12))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Text("CHOOSE A SLOT TO SWAP:")
                                .font(.custom("PressStart2P-Regular", size: 10))
                                .foregroundColor(.yellow)
                            
                            HStack(spacing: 15) {
                                ForEach(userViewModel.player.equippedCharacters, id: \.self) { equippedId in
                                    if let char = GameCatalog.itemCatalog[equippedId] {
                                        Button(action: {
                                            if let newId = characterToEquip {
                                                userViewModel.equipCharacter(newId, replacing: equippedId)
                                            }
                                            showSwapOverlay = false
                                            characterToEquip = nil
                                        }) {
                                            VStack {
                                                Image(char.imageName)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 60, height: 60)
                                                Text(char.name.uppercased())
                                                    .font(.custom("PressStart2P-Regular", size: 6))
                                                    .foregroundColor(.white)
                                                    .lineLimit(1)
                                                    .truncationMode(.tail)
                                            }
                                            .padding(8)
                                            .frame(width: 80, height: 90)
                                            .background(Color.black.opacity(0.6))
                                            .border(Color.yellow, width: 2)
                                        }
                                    }
                                }
                            }
                            
                            Button(action: {
                                showSwapOverlay = false
                                characterToEquip = nil
                            }) {
                                Text("CANCEL")
                                    .font(.custom("PressStart2P-Regular", size: 12))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(4)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 20)
                        .background(Color.black)
                        .cornerRadius(12)
                        .border(Color.white, width: 2)
                        .padding(20)
                    }
                }
            }
        )
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CharacterArchiveView(userViewModel: UserViewModel())
}
