//
//  HTPView.swift
//  superduperproject
//
//  Created by Ashley Ni on 4/15/26.
//

import SwiftUI

struct HTPView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack
        {
            Text("HOW TO PLAY")
                .font(.custom("PressStart2P-Regular", size: 28))
                .foregroundColor(.white)
                .padding(.top, 40)
            
            ScrollView{
                VStack(spacing: 20){
                    guideSection(title: "1. EARNING $$", content: "Tap the big 'TAP FOR $$$' button on the front screen! Each tap adds to your balance.")
                    guideSection(title: "2. BLIND BOXES", content: "Go to the Store and spend your money on Blind Boxes to get random character drops!")
                    guideSection(title: "3. UNLOCKING", content: "Characters are unlocked via Blind Boxes. Check your 'Archives' to see who you've collected.")
                    guideSection(title: "4. WHAT IS MPS?", content: "MPS stands for 'Money Per Second.' Some characters generate money automatically even when you aren't tapping!")
                    guideSection(title: "5. PROGRESS", content: "Unlock rare characters to boost your MPS and save up for the most expensive boxes in the Store.")
                }
                .padding()
            }
            
            Button (action: {
                dismiss()
            }) {
                Text("BACK")
                    .font(.custom("PressStart2P-Regular", size: 18))
                    .frame(width: 150, height: 45)
                    .background(Color(red: 1.0, green: 0.6, blue: 0.6))
                    .foregroundColor(.black)
            }
            .padding(.bottom, 20)
        }
        .navigationBarBackButtonHidden(true)
    }
    func guideSection(title: String, content: String) -> some View {
        DisclosureGroup(
            content: {
                Text(content)
                    .font(.custom("PressStart2P-Regular", size: 12))
                    .foregroundColor(.white)
                    .padding(.top, 10)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(8)
            },
            label: {
                Text(title)
                    .font(.custom("PressStart2P-Regular", size: 14))
                    .foregroundColor(.black)
            }
        )
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(0)
    }
}

#Preview {
    HTPView()
}
