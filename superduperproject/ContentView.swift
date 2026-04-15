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
    @EnvironmentObject var userVM: UserViewModel

    var body: some View {
        Group {
            if auth.user != nil {
                HomescreenView(userViewModel: userVM)
            } else {
                AuthView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
