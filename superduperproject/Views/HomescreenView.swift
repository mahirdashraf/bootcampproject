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
                    
                    NavigationLink(destination: FrontscreenView(userViewModel: userViewModel)){
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
        }
    }
}

#Preview {
    HomescreenView(userViewModel: UserViewModel())}
