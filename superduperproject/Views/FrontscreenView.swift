//
//  FrontscreenView.swift
//  
//
//  Created by Ashley Ni on 4/6/26.
//

import SwiftUI

struct FrontscreenView: View {
    //temp vars
    var balance: Int = 0
    var mps: Int = 0
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack{
            VStack(spacing: 20){
                HStack(spacing: 40) {
                    Text("MPS: \(mps)")
                        .padding(10)
                        .border(Color.black, width: 1)
                    Text("MONEY BALANCE: \(balance)")
                        .padding(10)
                        .border(Color.black, width: 1)
                }
                .font(.custom("PressStart2P-Regular", size: 10))
                .foregroundColor(.black)
                
                Button(action: {
                    print("button pressed")
                }) {
                    Text("CHARACTER ARCHIVES")
                        .font(.custom("PressStart2P-Regular", size: 14))
                        .frame(width: 375, height: 60)
                        .background(Color(red: 0.8, green: 0.6, blue: 1.0))
                        .foregroundColor(.black)
                    
                }
            }
            
            HStack(spacing: 20){
                Button(action: {
                    print("button pressed")
                }) {
                    Text("TAP FOR $$")
                        .font(.custom("PressStart2P-Regular", size: 20))
                        .frame(width: 175, height: 175)
                        .background(Color(red: 0.6, green: 1.0, blue: 0.6))
                        .foregroundColor(.black)
                }
                
                Button(action: {
                    print("button pressed")
                }) {
                    Text("STORE")
                        .font(.custom("PressStart2P-Regular", size: 20))
                        .frame(width: 175, height: 175)
                        .background(Color(red: 1.0, green: 0.8, blue: 0.4))
                        .foregroundColor(.black)
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
                    .foregroundColor(.black)
            }
            .padding(.bottom, 20)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}

    
    #Preview {
        FrontscreenView()
    }
