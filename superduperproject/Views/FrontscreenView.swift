//
//  FrontscreenView.swift
//  
//
//  Created by Ashley Ni on 4/6/26.
//

import SwiftUI

struct FrontscreenView: View {
    @ObservedObject var userViewModel: UserViewModel
    @Environment(\.dismiss) var dismiss
    
    // Placeholder UI only; equipped-character data can be wired in later.
    private let equippedCharacterPlaceholders = ["Slot 1", "Slot 2", "Slot 3"]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack{
                VStack(spacing: 25){
                    HStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("MPS")
                                .font(.custom("PressStart2P-Regular", size: 12))
                                .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.6))
                            Text("$\(Int(userViewModel.player.moneyPerSecond))")
                                .font(.custom("PressStart2P-Regular", size: 14))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(Color.black.opacity(0.5))
                        .border(Color(red: 0.6, green: 1.0, blue: 0.6), width: 2)
                        .frame(maxWidth: 110)
                        
                        VStack(spacing: 5) {
                            Text("BALANCE")
                                .font(.custom("PressStart2P-Regular", size: 12))
                                .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.6))
                            Text("$\(Int(userViewModel.player.totalMoney))")
                                .font(.custom("PressStart2P-Regular", size: 14))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(Color.black.opacity(0.5))
                        .border(Color(red: 0.6, green: 1.0, blue: 0.6), width: 2)
                    }
                    .frame(height: 60)
                    .frame(width: 375)
                    
                    NavigationLink(destination: CharacterArchiveView(userViewModel: userViewModel))
                    {
                        Text("CHARACTER ARCHIVES")
                            .font(.custom("PressStart2P-Regular", size: 14))
                            .frame(width: 375, height: 60)
                            .background(Color(red: 0.8, green: 0.6, blue: 1.0))
                            .foregroundColor(.black)
                        
                    }
                }
                
                HStack(spacing: 20){
                    NavigationLink {
                        FullGameView(userViewModel: userViewModel)
                    } label: {
                        Text("GAMES")
                            .font(.custom("PressStart2P-Regular", size: 20))
                            .multilineTextAlignment(.center)
                            .frame(width: 175, height: 175)
                            .background(Color(red: 0.6, green: 1.0, blue: 0.6))
                            .foregroundColor(.black)
                    }
                    NavigationLink(destination: StoreView(userViewModel: userViewModel))
                    {
                        Text("STORE")
                            .font(.custom("PressStart2P-Regular", size: 20))
                            .frame(width: 175, height: 175)
                            .background(Color(red: 1.0, green: 0.8, blue: 0.4))
                            .foregroundColor(.black)
                    }
                }
                .padding(40)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("EQUIPPED CHARACTERS")
                        .font(.custom("PressStart2P-Regular", size: 11))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 10) {
                        ForEach(equippedCharacterPlaceholders, id: \.self) { slot in
                            VStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 0)
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 90, height: 90)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.white)
                                    )
                                Text(slot)
                                    .font(.custom("PressStart2P-Regular", size: 7))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(12)
                .frame(width: 375)
                .background(Color.black.opacity(0.5))
                .border(Color(red: 0.6, green: 1.0, blue: 0.6), width: 2)
                
                
                Button (action: {
                    dismiss()
                }) {
                    Text("BACK")
                        .font(.custom("PressStart2P-Regular", size: 18))
                        .frame(width: 150, height: 45)
                        .background(Color(red: 1.0, green: 0.6, blue: 0.6))
                        .foregroundColor(.black)
                }.padding()
                .padding(.bottom, 10)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            userViewModel.setItemLookup({GameCatalog.itemCatalog[$0]})
            userViewModel.startEarningLoop()
        }
    }
}

    
#Preview {
    FrontscreenView(userViewModel: UserViewModel())
}
