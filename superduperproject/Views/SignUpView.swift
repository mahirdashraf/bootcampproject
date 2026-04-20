//
//  SignUpView.swift
//  superduperproject
//
//  Created by Juliana Martinez on 4/19/26.
//
import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("CREATE AN ACCOUNT")
                    .font(.custom("PressStart2P-Regular", size: 20))
                    .foregroundColor(.white).padding(30)
                
                VStack {
                    Text("Enter a valid email")                    .font(.custom("PressStart2P-Regular", size: 9))
                        .foregroundColor(.white)
                        .frame(width: 350, alignment: .leading)
                    ZStack(alignment: .leading) {
                        if email.isEmpty {
                            Text("email")
                                .font(.custom("PressStart2P-Regular", size: 12))
                                .foregroundColor(Color.white.opacity(0.4))
                                .padding(.leading, 9)
                        }
                        TextField("", text: $email)
                            .font(.custom("PressStart2P-Regular", size: 12))
                            .foregroundColor(.white)
                            .padding(.leading, 9)
                            .autocorrectionDisabled(true)
                    }
                    .frame(width: 360, height: 45)
                    .background(Color.black.opacity(0.3)).padding(9)
                }
                VStack {
                    Text("Enter a valid password")                    .font(.custom("PressStart2P-Regular", size: 9))
                        .foregroundColor(.white)
                        .frame(width: 350, alignment: .leading)
                    
                    ZStack(alignment: .leading) {
                        if password.isEmpty {
                            Text("password")
                                .font(.custom("PressStart2P-Regular", size: 12))
                                .foregroundColor(Color.white.opacity(0.4))
                                .padding(.leading, 9)
                        }
                        SecureField("", text: $password)
                            .font(.custom("PressStart2P-Regular", size: 15))
                            .foregroundColor(.white)
                            .padding(.leading, 9)
                            .autocorrectionDisabled(true)
                    }
                    .frame(width: 360, height: 45)
                    .background(Color.black.opacity(0.3)).padding(9)
                }
                Button {
                    auth.signUp(email: email, password: password)
                } label: {
                    Text("SIGN UP")
                        .font(.custom("PressStart2P-Regular", size: 10))
                        .frame(width: 300)
                        .padding()
                        .background(Color(red: 0.35, green: 0.75, blue: 0.45))                        .foregroundColor(.white)
                }.padding()
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
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
        }.navigationBarBackButtonHidden(true)
    }
}
#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
