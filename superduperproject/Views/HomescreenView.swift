//
//  HomescreenView.swift
//  superduperproject
//
//  Created by Ashley Ni on 4/14/26.
//

import SwiftUI

struct HomescreenView: View {
    @ObservedObject var userViewModel: UserViewModel
    @EnvironmentObject var auth: AuthViewModel
    @State private var goToFrontscreen = false
    @State private var showOfflineWelcome = false
    @State private var offlineEarnings = 0.0
    
    var body: some View {
        NavigationStack{
            ZStack {
                Image("homescreen")
                    .resizable()
                    .scaledToFill()
                    .overlay(Color.black.opacity(0.4))
                    .ignoresSafeArea()
                
                VStack(spacing: 40){
                    Spacer()
                    Text("COLLECTORA")
                        .font(.custom("PressStart2P-Regular", size: 35))
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                    
                    Button(action: {
                        if let earned = userViewModel.takeOfflineEarningsForWelcomeIfNeeded() {
                            offlineEarnings = earned
                            showOfflineWelcome = true
                        } else {
                            goToFrontscreen = true
                        }
                    }) {
                        Text("PLAY")
                            .font(.custom("PressStart2P-Regular", size: 20))
                            .frame(width: 200, height: 80)
                            .background(Color(red: 0.6, green: 0.8, blue: 1.0))
                            .foregroundColor(.white)
                            .cornerRadius(0)
                    }
                    NavigationLink(destination: HTPView())
                    {
                        Text("HOW TO PLAY")
                            .font(.custom("PressStart2P-Regular", size: 20))
                            .frame(width: 200, height: 80)
                            .background(Color(red: 1.0, green: 0.6, blue: 0.6))
                            .foregroundColor(.white)
                            .cornerRadius(0)
                    }
                    Button(action: {
                        auth.signOut()
                    }) {
                        Text("LOG OUT")
                            .font(.custom("PressStart2P-Regular", size: 20))
                            .frame(width: 200, height: 80)
                            .background(Color(red: 1.0, green: 0.4, blue: 0.4))
                            .foregroundColor(.white)
                            .cornerRadius(0)
                    }
                    Spacer()
                }.padding()
            }
            .fullScreenCover(isPresented: $showOfflineWelcome) {
                OfflineEarningsView(earnedMoney: offlineEarnings) {
                    showOfflineWelcome = false
                    goToFrontscreen = true
                }
            }
            .navigationDestination(isPresented: $goToFrontscreen) {
                FrontscreenView(userViewModel: userViewModel)
            }
        }
    }
}

private struct OfflineEarningsView: View {
    let earnedMoney: Double
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()

            VStack(spacing: 18) {
                Text("WELCOME BACK")
                    .font(.custom("PressStart2P-Regular", size: 20))
                    .foregroundColor(.white)

                Text("While you were gone, your multiverse friends made")
                    .font(.custom("PressStart2P-Regular", size: 10))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)

                Text("$\(Int(earnedMoney))")
                    .font(.custom("PressStart2P-Regular", size: 24))
                    .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.6))

                Button("CONTINUE") {
                    onContinue()
                }
                .font(.custom("PressStart2P-Regular", size: 12))
                .padding(.horizontal, 22)
                .padding(.vertical, 12)
                .background(Color(red: 1.0, green: 0.6, blue: 0.6))
                .foregroundColor(.black)
                .cornerRadius(8)
            }
            .padding(24)
            .frame(maxWidth: 360)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.black.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    HomescreenView(userViewModel: UserViewModel())}
