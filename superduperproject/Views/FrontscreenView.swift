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
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack{
                VStack(spacing: 25){
                    HStack(spacing: 8) {
                        VStack(spacing: 5) {
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
                            .foregroundColor(.white)
                        
                    }
                }
                
                HStack(spacing: 20){
                    Button(action: {
                        userViewModel.addMoney(20.0)
                        userViewModel.saveToLocal()
                    }) {
                        Text("TAP FOR $$$")
                            .font(.custom("PressStart2P-Regular", size: 20))
                            .frame(width: 175, height: 175)
                            .background(Color(red: 0.6, green: 1.0, blue: 0.6))
                            .foregroundColor(.white)
                    }
                    
                    NavigationLink(destination: StoreView(userViewModel: userViewModel))
                    {
                        Text("STORE")
                            .font(.custom("PressStart2P-Regular", size: 20))
                            .frame(width: 175, height: 175)
                            .background(Color(red: 1.0, green: 0.8, blue: 0.4))
                            .foregroundColor(.white)
                    }
                }
                .padding(40)
                
                
                Button (action: {
                    dismiss()
                }) {
                    Text("BACK")
                        .font(.custom("PressStart2P-Regular", size: 18))
                        .frame(width: 150, height: 45)
                        .background(Color(red: 1.0, green: 0.6, blue: 0.6))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 20)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            userViewModel.loadPlayerPreferCloud()
            userViewModel.recomputeMoneyPerSecond()
            userViewModel.startEarningLoop()
        }
    }
}

    
    #Preview {
        FrontscreenView(userViewModel: UserViewModel())
    }
