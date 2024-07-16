//
//  SeatBook.swift
//  BiblioFi
//
//  Created by Nikunj Tyagi on 12/07/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct SeatBook: View {
    @State private var selectedDate = Date()
    @State private var selectedTimeSlot = "09:00 AM - 11:00 AM"
    @State private var statusMessage: String = ""
    @State private var reservations = [Reservation]()
    @State private var memberId: String = Auth.auth().currentUser?.uid ?? ""
    let timeSlots = ["09:00 AM - 11:00 AM", "11:00 AM - 01:00 PM", "01:00 PM - 03:00 PM", "03:00 PM - 05:00 PM"]

    var body: some View {
        VStack {Text("Book Seat in Library")
                                        .font(.largeTitle)
                                        .bold()
                                        .padding([.leading, .top])
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .padding()

            Picker("Select Time Slot", selection: $selectedTimeSlot) {
                ForEach(timeSlots, id: \.self) { slot in
                    Text(slot)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

            Button(action: reserveSeat) {
                Text("Reserve Seat")
                    .padding()
                    .background(Color(hex: "#945200"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            Text(statusMessage)
                .padding()
                .foregroundColor(.red)

            Divider()

            Text("My Reservation Requests")
                .font(.headline)
                .padding()

            List(reservations.filter {$0.memberId == memberId}) { reservation in
                VStack(alignment: .leading) {
                    Text("Date: \(reservation.selectedDate, formatter: dateFormatter)")
                    Text("Time Slot: \(reservation.selectedTimeSlot)")
                    Text("Status: \(reservation.status.capitalized)")
                        .foregroundColor(reservation.status == "approved" ? .green : .red)
                }
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#ffffff"), Color(hex: "#f1d4cf")]),
                                                          startPoint: .topLeading,
                                                          endPoint: .bottomTrailing)
                                   .edgesIgnoringSafeArea(.all))
                               .navigationBarTitle("Seat Booking", displayMode: .inline)
        .padding()
        .onAppear(perform: fetchMyReservations)
        
    }
    

    func reserveSeat() {
        guard let user = Auth.auth().currentUser else {
            statusMessage = "User not authenticated"
            return
        }
        
        let db = Firestore.firestore()
        let reservation = Reservation(
            memberId: memberId,
            memberEmail: user.email ?? "unknown@example.com",
            selectedDate: selectedDate,
            selectedTimeSlot: selectedTimeSlot,
            status: "pending",
            timestamp: Timestamp(date: Date())
        )
        
        do {
            _ = try db.collection("seatReservations").addDocument(from: reservation) { error in
                if let error = error {
                    statusMessage = "Error: \(error.localizedDescription)"
                } else {
                    statusMessage = "Reservation Sent"
                    fetchMyReservations()
                }
            }
        } catch {
            statusMessage = "Error: \(error.localizedDescription)"
        }
    }

    func fetchMyReservations() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("seatReservations")
            .whereField("memberId", isEqualTo: user.uid)
            .order(by: "timestamp", descending: true) // Order by timestamp
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                } else {
                    self.reservations = querySnapshot?.documents.compactMap { document -> Reservation? in
                        try? document.data(as: Reservation.self)
                    } ?? []
                }
            }
    }
}

struct Reservation: Identifiable, Codable {
    @DocumentID var id: String?
    var memberId: String
    var memberEmail: String
    var selectedDate: Date
    var selectedTimeSlot: String
    var status: String
    var timestamp: Timestamp
}
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()
