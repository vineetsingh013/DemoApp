//
//  BookDescription.swift
//  BiblioFi
//
//  Created by Ayushman Singh Rajawat on 04/07/24.
//
import SwiftUI

struct BookDescription: View {
    @State private var showDurationPicker = false
    var body: some View {
        VStack {
            ScrollView {
                
                // Book image and details
                HStack(alignment: .top) {
                    Image("dark_world") // Replace with the actual image name
                        .resizable()
                        .frame(width: 120, height: 180)
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Dark World")
                            .font(.custom("AvenirNext-Bold", size: 30))
                            .fontWeight(.bold)
                        
                        Text("By Kathryn Bywater")
                            .font(.custom("AvenirNext-Regular", size: 15))                            .foregroundColor(.gray)
                        
                        HStack {
                            ForEach(0..<5) { index in
                                Image(systemName: index < 4 ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                        }
                        Text(true ? "Available" : "Out of Stock")
                            .font(.custom("AvenirNext-Regular", size: 15))
                            .foregroundColor(true ? .green : .red)
                    }
                    Spacer()
                    
                    // Heart button
                    Button(action: {
                        // Action for the heart button
                    }) {
                        Image(systemName: "heart")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                    }
                }
                .padding()
                Divider()
                
                // Book information
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Title: ")
                            .font(.custom("AvenirNext-Bold", size: 16))
                        Text("Dark World")
                            .font(.custom("AvenirNext-Regular", size: 16))
                    }
                    
                    HStack {
                        Text("Author: ")
                            .font(.custom("AvenirNext-Bold", size: 16))
                        Text("Kathryn Bywater")
                            .font(.custom("AvenirNext-Regular", size: 16))
                    }
                    
                    HStack {
                        Text("ISBN: ")
                            .font(.custom("AvenirNext-Bold", size: 16))
                        Text("9780439023528")
                            .font(.custom("AvenirNext-Regular", size: 16))
                    }
                    
                    HStack {
                        Text("Publisher: ")
                            .font(.custom("AvenirNext-Bold", size: 16))
                        Text("Scholastic Press (2008)")
                            .font(.custom("AvenirNext-Regular", size: 16))
                    }
                    
                    HStack {
                        Text("Status: ")
                            .font(.custom("AvenirNext-Bold", size: 16))
                        Text("Available")
                            .font(.custom("AvenirNext-Regular", size: 16))
                    }
                    
                    HStack {
                        Text("Number of Copies: ")
                            .font(.custom("AvenirNext-Bold", size: 16))
                        Text("3 available")
                            .font(.custom("AvenirNext-Regular", size: 16))
                    }
                    
                    Text("Description: ")
                        .font(.custom("AvenirNext-Bold", size: 16))
                        .padding(.top, 1)
                    
                    Text("In a dystopian future, Katniss Everdeen volunteers to take her sister's place in a televised fight-to-the-death competition.")
                        .font(.custom("AvenirNext-Regular", size: 16))
                }
                .padding()
                

            }

            
            // Checkout and Add to Cart buttons
            Divider()
            HStack {
                
                Button(action: {
                    showDurationPicker = true
                    // Action for the Checkout button
                })
                {
                    HStack {
                        Image(systemName: "cart")
                        Text("Checkout")
                            .font(.custom("AvenirNext-Bold", size: 18))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#945200"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                
                Button(action: {
                    // Action for the Add to Cart button
                }) {
                    HStack {
                        Image(systemName: "bag")
                        Text("Add to Cart")
                            .font(.custom("AvenirNext-Bold", size: 18))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#945200"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding()
            .sheet(isPresented: $showDurationPicker) {
                            DurationPickerView(isPresented: $showDurationPicker)
                        }
        }
        .background(Color(hex: "#F9EDEA"))
        .navigationBarHidden(true)
    }
}
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}



struct BookDescription_Previews: PreviewProvider {
    static var previews: some View {
        BookDescription()
    }
}
#Preview {
    BookDescription()
}
