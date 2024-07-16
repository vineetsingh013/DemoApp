//
//  LaunchView.swift
//  BiblioFi
//
//  Created by Nikunj Tyagi on 15/07/24.
//


import SwiftUI

struct LaunchView: View {
    @Binding var isOnboardingViewActive: Bool
    @State private var showOwl = false
    @State private var navigateToLogin = false
    
    var body: some View {
        if navigateToLogin {
            OnboardingView(isOnboardingViewActive: $isOnboardingViewActive)
        } else {
            ZStack {
               
                LinearGradient(gradient: Gradient(colors: [Color(hex: "#ffffff"), Color(hex: "#f1d4cf")]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
//                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    HStack(spacing: 0) {
                        Text("Bibl")
                            .font(.custom("Avenir Next", size: 80))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        if showOwl {
                            Image("oreoo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 60)
                                .transition(.scale)
                        }
                        
                        Text("Fi")
                            .font(.custom("Avenir Next", size: 80))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                }
                .onAppear {
                    withAnimation(Animation.easeIn(duration: 0.6).delay(0.6)) {
                        showOwl = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                        withAnimation {
                            navigateToLogin = true
                        }
                    }
                }
            }
        }
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isOnboardingViewActive: .constant(true))
    }
}
