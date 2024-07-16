//
//  GoogleApifetch.swift
//  BiblioFi
//
//  Created by sourav_singh on 08/07/24.
//

import SwiftUI
import Combine

struct Book: Codable {
    let volumeInfo: VolumeInfo
}

struct VolumeInfo: Codable {
    let title: String
    let imageLinks: ImageLinks?
}

struct ImageLinks: Codable {
    let thumbnail: String
}

class BookViewModel: ObservableObject {
    @Published var book: Book?

    func fetchBookData() {
        guard let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=isbn:9780140449136") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("No data returned or there was an error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let bookData = try JSONDecoder().decode(Book.self, from: data)
                DispatchQueue.main.async {
                    self.book = bookData
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
}

