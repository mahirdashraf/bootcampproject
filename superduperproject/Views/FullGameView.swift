//
//  FullGameView.swift
//  superduperproject
//
//  Created by Juliana Martinez on 4/20/26.
//
import SwiftUI

struct FullGameView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var userViewModel: UserViewModel

    let columns = [
            GridItem(.flexible())]
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            VStack {
                Spacer()
                Spacer()
                Text("MINI-GAMES").font(.custom("PressStart2P-Regular", size: 25))                   .foregroundColor(.white).padding(30)
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible())
                    ], spacing: 20) {
                        NavigationLink {
                            FlappyBirdView(userViewModel: userViewModel)
                        } label: {
                            GameTile(title: "FLAPPY BIRD")
                        }
                    }
                    .padding()
                }
            }
            Button {
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("BACK")
                }
                .font(.custom("PressStart2P-Regular", size: 10))
                .foregroundColor(.white)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding()
        }.navigationBarBackButtonHidden(true)
    }
}
struct GameTile: View {
    let title: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 1.0, green: 0.8, blue: 0.4))
                .frame(height: 120)
            Text(title)
                .font(.custom("PressStart2P-Regular", size: 17))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    FullGameView(userViewModel: UserViewModel())
}
