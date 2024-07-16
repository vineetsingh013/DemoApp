

//
//  ProfileView.swift
//  BiblioFi
//
//  Created by Nikunj Tyagi on 05/07/24.
//
import SwiftUI

struct ProfileView: View {
    var body: some View {
        
        ZStack {
            
            ScrollView {
                // Heading for My Books
                Text("My Books")
                    .font(.largeTitle)
                    .bold()
                    .padding([.leading, .top])
                
                // First section: Issued Books
                VStack(alignment: .leading) {
                    HStack {
                        Text("Issued Books")
                            .font(.title2)
                            .bold()
                        Spacer()
                        NavigationLink(destination: IssuedBooksView()) {
                            Text("See All")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 30) {
                            ForEach(0..<5) { _ in
                                IssuedBookCard()
                                    .frame(width: 200, height: 150) // Adjusted size
                            }
                            .padding(.horizontal)
                            Spacer()
                            
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
                .padding(.horizontal)
                
                // Second section: My Requests
                VStack(alignment: .leading) {
                    HStack {
                        Text("Requests")
                            .font(.title2)
                            .bold()
                        Spacer()
                        NavigationLink(destination: RequestsView()) {
                            Text("See All")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack {
                        ForEach(0..<5) { _ in
                            NavigationLink(destination: RequestDetailView()) {
                                RequestListItem()
                            }
//                            .buttonStyle(PlainButtonStyle())
                        }
                    }
//                    .listStyle(PlainListStyle())
                }
                .padding(.top)
                .padding(.all)
                Spacer()
                
            }
            .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#ffffff"), Color(hex: "#f1d4cf")]),
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all))
        }
    }
    
    
    struct IssuedBookCard: View {
        var body: some View {
            HStack {
                Image("Book")
                    .resizable()
                    .frame(width: 60, height: 90) // Adjusted size
                    .padding()
                
                VStack(alignment: .leading) {
                    Text("Book Title")
                        .font(.headline)
                    
                    Text("Author Name")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                    
                    Text("4 Days Left")
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                        .padding(.top, 2)
                }
                Spacer()
            }
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 0.5)
            .padding(.vertical, 10) // Adjusted padding
            .frame(width: 250, height: 150) // Adjusted size
        }
    }
    
    struct RequestListItem: View {
        var body: some View {
            HStack {
                Image( "Book")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding()
                
                VStack(alignment: .leading) {
                    Text("Book Title")
                        .font(.headline)
                        .foregroundColor(.black)
                    Text("Author Name")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                  
                    HStack {
                      
                        Text("Pending")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(4)
                            .background(Color.yellow.opacity(0.4))
                            .cornerRadius(4)
                    }
                }
                Spacer()
            }
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
            .cornerRadius(8)
            .shadow(radius: 0)
            .padding(.vertical, 5)
            .background(.white)
        }
    }
}
    struct IssuedBooksView: View {
        var body: some View {
            Text("Issued Books Full List")
        }
    }
    
    struct RequestsView: View {
        var body: some View {
            Text("Requests Full List")
        }
    }
    
    struct RequestDetailView: View {
        var body: some View {
            Text("Request Detail View")
        }
    }
    
    struct ProfileView_Previews: PreviewProvider {
        static var previews: some View {
            ProfileView()
        }
    }
