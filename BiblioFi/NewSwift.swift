//
//  NewSwift.swift
//  BiblioFi
//
//  Created by Nikunj Tyagi on 04/07/24.
//

import SwiftUI

struct NewSwift: View {
   
    var body: some View {
        TabView {
            // Home Tab
            NavigationView {
                HomeView()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            
            // Discover Tab
            NavigationView {
////                DiscoverView()
//                    .navigationBarBackButtonHidden(true)
//                    .navigationBarHidden(true)
                SeatBook()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: "sparkles")
                Text("Reserve")
            }
            
            // Library Tab
            NavigationView {
                MyRequestView()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
               
            }
            .tabItem {
                Image(systemName: "books.vertical")
                Text("Library")
            }
            

        }
        .accentColor(Color(hex: "#8B551B")) // Set accent color to dark color (#8B551B)
        .background(Color.white.opacity(0.9)) // Set background color with light transparency
    }
}

struct NewScreen_Previews: PreviewProvider {
    static var previews: some View {
        NewSwift()
    }
}

