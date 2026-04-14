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
        VStack {
            Text("Login").font(.largeTitle).bold()
            TextField("Email", text: $email).textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password).textFieldStyle(.roundedBorder)
            Button("Sign in") {
                auth.signIn(email: email, password: password)
            }
            Button("Create Account") {
                auth.signUp(email: email, password: password)
            }
        }.padding()
    }
}
