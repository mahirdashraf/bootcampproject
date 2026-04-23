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
    @State private var showValidationAlert = false
    @State private var showAuthAlert = false
    @State private var validationMessage = ""
    
    var isEmailValid: Bool {
        email.contains("@") && email.lowercased().contains(".com")
    }
    
    var isPasswordValid: Bool {
        password.count >= 6
    }
    
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("CREATE AN ACCOUNT")
                    .font(.custom("PressStart2P-Regular", size: 20))
                    .foregroundColor(.white).padding(30)
                
                VStack {
                    Text("Enter a valid email")
                        .font(.custom("PressStart2P-Regular", size: 9))
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
                    Text("Enter a valid password")
                        .font(.custom("PressStart2P-Regular", size: 9))
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
                    handleSignUp()
                } label: {
                    Text("SIGN UP")
                        .font(.custom("PressStart2P-Regular", size: 10))
                        .frame(width: 300)
                        .padding()
                        .background(Color(red: 0.35, green: 0.75, blue: 0.45))
                        .foregroundColor(.white)
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
            if showValidationAlert {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 15) {
                        Text("INVALID INPUT")
                            .font(.custom("PressStart2P-Regular", size: 12))
                            .foregroundColor(.white)
                        
                        Text(validationMessage)
                            .font(.custom("PressStart2P-Regular", size: 10))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(6)
                        
                        Button {
                            showValidationAlert = false
                        } label: {
                            Text("OK")
                                .font(.custom("PressStart2P-Regular", size: 10))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .foregroundColor(.black)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .padding(40)
                }
            } else if let error = auth.errorMessage {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 15) {
                        Text("SIGN UP FAILED")
                            .font(.custom("PressStart2P-Regular", size: 12))
                            .foregroundColor(.white)
                        
                        Text(error)
                            .font(.custom("PressStart2P-Regular", size: 10))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(6)
                        
                        Button {
                            auth.errorMessage = nil
                        } label: {
                            Text("OK")
                                .font(.custom("PressStart2P-Regular", size: 10))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .foregroundColor(.black)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .padding(40)
                }
            }
        }.navigationBarBackButtonHidden(true)
    }
    private func handleSignUp() {
        var errors: [String] = []
        if !isEmailValid {
            errors.append("Email must contain @ and .com")
        }
        if !isPasswordValid {
            errors.append("Password must be at least 6 characters")
        }
        if !errors.isEmpty {
            validationMessage = errors.joined(separator: "\n\n")
            showValidationAlert = true
            return
        }
        auth.signUp(email: email, password: password)
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
