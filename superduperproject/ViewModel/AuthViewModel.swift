//
//  AuthViewModel.swift
//  superduperproject
//
//  Created by Juliana Martinez on 4/14/26.
//

import FirebaseAuth
import Combine
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var user: User?
    private var authListener: AuthStateDidChangeListenerHandle?
    
    init() {
        authListener = Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                self.user = user
            }
        }
    }
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    func signOut() {
        try? Auth.auth().signOut()
    }
}
