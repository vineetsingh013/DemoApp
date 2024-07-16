//
//  secondOnboarding.swift
//  BiblioFi
//
//  Created by Nikunj Tyagi on 10/07/24.
//
import SwiftUI

struct secondOnboarding: View {
    @AppStorage("onboarding") var isOnboardingViewActive = false
    @State private var isAnimating = false
    @State private var navigateToMajorView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // MARK: - Header
                Spacer()
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color(hex: "#ffffff"), Color(hex: "#f1d4cf")]),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                        .edgesIgnoringSafeArea(.all)
                    CircleGroupView(shapeColor: Color(hex: "f1d4cf"), shapeOpacity: 0.2)
                    Image("Image")
                        .resizable()
                        .frame(width: 200, height: 190)
                        .scaledToFit()
                        .padding()
                        .offset(y: isAnimating ? 35 : -35)
                        .animation(Animation.easeOut(duration: 4).repeatForever(), value: isAnimating)
                }
                
                // MARK: - Center
                Text("Issue books directly from your phone without waiting in line.")
                    .font(.title3)
                    .fontWeight(.black)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                // MARK: - Footer
                Spacer()
                
                // Continue Button
                NavigationLink(destination: MajorScreen(), isActive: $navigateToMajorView) {
                    Button(action: {
                        navigateToMajorView = true
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#945200")
                            .cornerRadius(15))
                            .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(false)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct secondOnboarding_Previews: PreviewProvider {
    static var previews: some View {
        secondOnboarding()
    }
}
