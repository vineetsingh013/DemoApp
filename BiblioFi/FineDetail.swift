//
//  FineDetail.swift
//  BiblioFi
//
//  Created by Nikunj Tyagi on 12/07/24.
//

import SwiftUI

struct FineDetail: View {
    var body: some View {
        NavigationView {
            List {
                ForEach(bookData) { book in
                    HStack {
                        Image(book.imageName) // Replace with your image asset name
                            .resizable()
                            .frame(width: 50, height: 75)
                            .cornerRadius(5)
                        
                        VStack(alignment: .leading) {
                            Text(book.title)
                                .font(.headline)
                            Text(book.author)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text("Fine:")
                                Text("$\(book.fine, specifier: "%.2f")")
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Fine")
        }
    }
}

// Sample book data
struct Book4: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let author: String
    let fine: Double
}

let bookData = [
    Book4(imageName: "book1", title: "Book Title 1", author: "Author 1", fine: 1.99),
    Book4(imageName: "book2", title: "Book Title 2", author: "Author 2", fine: 2.49),
    Book4(imageName: "book3", title: "Book Title 3", author: "Author 3", fine: 0.99)
]

#Preview {
    FineDetail()
}
