//
//  MajorScreen.swift
//  BiblioFi
//
//  Created by Nikunj Tyagi on 10/07/24.

import SwiftUI

struct MajorScreen: View {
    
    var body: some View {
        
        NavigationView {
            ZStack{
                LinearGradient(gradient: Gradient(colors: [Color(hex: "#ffffff"), Color(hex: "#f1d4cf")]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                              
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 100)
                    
                    
                    Text("Welcome")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                    Text("Please login or create an account to continue")
                        .font(.subheadline)
                        .padding(.bottom, 40)
                    Image("Boarding")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 280, height: 280)
                        .padding(.top)
                    
                    NavigationLink(destination: SignUpView().navigationBarBackButtonHidden(true)) {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#945200"))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    NavigationLink(destination: LoginPage().navigationBarBackButtonHidden(true)) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#945200"))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
}


#Preview {
    MajorScreen()
}
