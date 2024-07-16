//
//  DurationPickerView.swift
//  BiblioFi
//
//  Created by Ayushman Singh Rajawat on 05/07/24.
//
import SwiftUI

struct DurationPickerView: View {
    @Binding var isPresented: Bool
    @State private var selectedDays: Int = 1
    @State private var reserveBook: Bool = false
    @State private var showConfirmationAlert = false // State to control showing the confirmation alert
    
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Issue Your Book")
                .font(.custom("AvenirNext-Bold", size: 24))
            Image("owl_wings")
                .resizable()
                .frame(width: 97, height: 67)
                .cornerRadius(8)
           Text("Book will be issued for 7 days.")
                .font(.custom("AvenirNext-Regular", size: 14))
            
//            Picker("Duration", selection: $selectedDays) {
//                ForEach(1..<8) {
//                    Text("\($0) day\($0 > 1 ? "s" : "")").tag($0)
//                }
//            }
//            .pickerStyle(WheelPickerStyle())
//            .frame(maxWidth: 200, maxHeight: 150)
//            .clipped()
//            
            
            HStack(spacing: 20) {
                Button(action: {
                    // Handle the selection and dismiss the modal
                    isPresented = false
                    showConfirmationAlert = true
                    // Add your logic to handle the selected duration
                }) {
                    Text("Send Issue Request")
                        .font(.custom("AvenirNext-Bold", size: 18))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#945200"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
            }
        }
        .padding()
        .background(Color(hex: "#F9EDEA"))
        .cornerRadius(20)
        .shadow(radius: 10)
        .alert(isPresented: $showConfirmationAlert) {
            Alert(title: Text("Request Sent"), message: Text("Your book request has been sent."), dismissButton: .default(Text("OK")))
            
        }
    }
}




