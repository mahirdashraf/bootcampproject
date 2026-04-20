//
//  Auth.swift
//  superduperproject
//
//  Created by Juliana Martinez on 4/14/26.
//

import SwiftUI
import FirebaseAuth


struct AuthView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.9)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    Text("COLLECTORA")
                        .font(.custom("PressStart2P-Regular", size: 35))
                        .foregroundColor(.clear)
                        .background(
                            Image("homescreen")
                                .resizable()
                                .scaledToFill()
                                .offset(x:0, y: -261)
                                .brightness(0.3)
                                .contrast(1.3)
                        )
                        .mask(
                            Text("COLLECTORA")
                                .font(.custom("PressStart2P-Regular", size: 35))
                        )
                        .fixedSize().padding(20)
                    VStack(spacing: 10) {
                        ZStack(alignment: .leading) {
                            if email.isEmpty {
                                Text("email")
                                    .font(.custom("PressStart2P-Regular", size: 12))
                                    .foregroundColor(Color.white.opacity(0.4))
                            }
                            TextField("", text: $email)
                                .font(.custom("PressStart2P-Regular", size: 12))
                                .foregroundColor(.white)
                                .autocorrectionDisabled(true)
                        }.padding(.horizontal, 10)
                            .frame(width: 360, height: 45)               .background(Color.black.opacity(0.3))
                        
                        ZStack(alignment: .leading) {
                            if password.isEmpty {
                                Text("password")
                                    .font(.custom("PressStart2P-Regular", size: 12))
                                    .foregroundColor(Color.white.opacity(0.4))
                            }
                            SecureField("", text: $password)
                                .font(.custom("PressStart2P-Regular", size: 12))
                                .foregroundColor(.white)
                                .autocorrectionDisabled(true)
                        }.padding(.horizontal, 10)
                            .frame(width: 360, height: 45)
                            .background(Color.black.opacity(0.3))
                    }
                    
                    VStack(spacing: 15) {
                        Button {
                            auth.signIn(email: email, password: password)
                        } label: {
                            Text("SIGN IN")
                                .font(.custom("PressStart2P-Regular", size: 10))
                                .frame(width: 325, height: 5)
                                .padding()
                                .background(Color(red: 1.0, green: 0.65, blue: 0.75))
                                .foregroundColor(.white)
                        }
                        NavigationLink {
                            SignUpView()
                                .environmentObject(auth)
                        }  label: {
                            HStack {
                                Text("Don't have an account?")           .font(.custom("PressStart2P-Regular", size: 10))                            .foregroundColor(.white)
                                Text("CREATE ONE")
                                    .font(.custom("PressStart2P-Regular", size: 10))
                                    .frame(width: 107, height: 5)
                                    .padding(10)
                                    .background(Color(red: 0.35, green: 0.75, blue: 0.45))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    Spacer()
                }
            }
        }
    }
}
#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
