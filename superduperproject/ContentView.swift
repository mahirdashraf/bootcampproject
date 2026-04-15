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
    @State private var showPlayDemo = false

    var body: some View {
        Group {
            if auth.user != nil {
                collectoraMenu
            } else {
                AuthView()
            }
        }
        .sheet(isPresented: $showPlayDemo) {
            ContentPreview()
        }
    }

    private var collectoraMenu: some View {
        VStack(spacing: 20) {
            Spacer()

            VStack(spacing: 18) {
                Text("collectora")
                    .font(.title)
                    .fontWeight(.semibold)

                VStack(spacing: 12) {
                    Button("play") {
                        showPlayDemo = true
                    }
                    .buttonStyle(.borderedProminent)

                    Button("exit") {
                        auth.signOut()
                    }
                    .buttonStyle(.bordered)
                }
            }.padding(20)
            .frame(maxWidth: 260)
            .padding(24)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
