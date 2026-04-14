//
//  ContentView.swift
//  superduperproject
//
//  Created by Ashley Ni on 3/16/26.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth



struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel
    var body: some View {
        Group {
            if auth.user != nil {
                login
            } else {
                AuthView()
            }
        }
    }
    private var login: some View {
        VStack {
            HStack {
                Button("sign out") {
                    auth.signOut()
                }
                Spacer()
            }.padding(20)
            Spacer()
            Text("is ts working 😭😭😭😭")
            Spacer()
            }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
