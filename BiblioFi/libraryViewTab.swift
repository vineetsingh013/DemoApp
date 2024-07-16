//
//  libraryViewTab.swift
//  BiblioFi
//
//  Created by Nikunj Tyagi on 10/07/24.
//
import SwiftUI

struct libraryViewTab: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Current Dues Section
                    Text("Current Dues")
                        .font(.title)
                        .padding(.leading)

                    HStack(spacing: 20) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.red)
                            .frame(height: 100)
                            .overlay(
                                Text("Pay Now")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Due Dates Section
                    Text("Due Dates")
                        .font(.title)
                        .padding(.leading)

                    HStack(spacing: 20) {
                        NavigationLink(destination: FineView()) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue)
                                .frame(height: 100)
                                .overlay(
                                    Text("See Fine")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                )
                        }
                        
                        NavigationLink(destination: CurrentBorrowingView()) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.green)
                                .frame(height: 100)
                                .overlay(
                                    Text("Current Borrowing")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                )
                        }
                    }
                    .padding(.horizontal)

                    // Book Your Seat Section
                    Text("Book Your Seat")
                        .font(.title)
                        .padding(.leading)

                    NavigationLink(destination: BookSeatView()) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange)
                            .frame(width: 330, height: 330)
                            .overlay(
                                Text("Book Now")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            )
                            .padding(.horizontal)
                    }

                    Spacer()
                }
            }
            .navigationTitle("Library")
        }
    }
}

// Placeholder views for the navigation destinations
struct FineView: View {
    @State private var selectedSegment = 0
    @State private var selectedDetailSegment = 0
    
    let segments = ["Option 1", "Option 2"]
    let segmentItems = [
        ["Item 1", "Item 2", "Item 3"],
        ["Item A", "Item B", "Item C"]
    ]
    
    let detailSegments = ["Detail 1", "Detail 2"]
    let detailSegmentItems = [
        ["Detail Item 1", "Detail Item 2", "Detail Item 3"],
        ["Detail Item A", "Detail Item B", "Detail Item C"]
    ]
    
    var body: some View {
        VStack {
            Picker("Options", selection: $selectedSegment) {
                ForEach(0..<segments.count) { index in
                    Text(self.segments[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            List(segmentItems[selectedSegment], id: \.self) { item in
                Text(item)
            }
            
            Picker("Details", selection: $selectedDetailSegment) {
                ForEach(0..<detailSegments.count) { index in
                    Text(self.detailSegments[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            List(detailSegmentItems[selectedDetailSegment], id: \.self) { item in
                Text(item)
            }
        }
        .navigationTitle("Fine")
    }
}

struct FineView_Previews: PreviewProvider {
    static var previews: some View {
        FineView()
    }
}

struct Book3: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let author: String
    let issuedDate: String
}

struct CurrentBorrowingView: View {
    let borrowedBooks: [Book3] = [
        Book3(image: "book_cover_1", title: "Book Title 1", author: "Author 1", issuedDate: "2024-01-01"),
        Book3(image: "book_cover_2", title: "Book Title 2", author: "Author 2", issuedDate: "2024-02-01"),
        Book3(image: "book_cover_3", title: "Book Title 3", author: "Author 3", issuedDate: "2024-03-01")
    ]
    
    var body: some View {
        List(borrowedBooks) { book in
            HStack {
                Image(book.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 70)
                    .cornerRadius(8)
                
                VStack(alignment: .leading) {
                    Text(book.title)
                        .font(.headline)
                    Text(book.author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Issued: \(book.issuedDate)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.leading, 8)
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Current Borrowing")
    }
}

struct CurrentBorrowingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CurrentBorrowingView()
        }
    }
}

struct BookSeatView: View {
    var body: some View {
        Text("Book Your Seat")
            .font(.title)
            .navigationTitle("Book Seat")
    }
}

#Preview {
    libraryViewTab()
}
