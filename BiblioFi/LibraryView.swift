import SwiftUI
import FirebaseFirestore

// MARK: - Data Models

struct Book2: Identifiable {
    var id = UUID()
    var title: String
    var author: String
    var image: String
    var rating: Double
    var thumbnail: String // modified
}

struct Author: Identifiable {
    var id = UUID()
    var name: String
    var image: String
}

class FirestoreManager: ObservableObject {
    @Published var books = [Book2]()
    
    private var db = Firestore.firestore()
    
    func fetchBooks(for category: String) {
        db.collection("Books").whereField("categories", arrayContains: category).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.books = querySnapshot?.documents.compactMap { document in
                    let data = document.data()
                    let title = data["title"] as? String ?? ""
                    let author = data["authors"] as? String ?? ""
                    
                    // Extracting the thumbnail URL from the nested structure
                    let imageLinks = data["imageLinks"] as? [String: Any]
                    let thumbnail = imageLinks?["thumbnail"] as? String ?? ""
                    
                    let rating = data["rating"] as? Double ?? 0.0
                    
                    return Book2(title: title, author: author, image: thumbnail, rating: rating, thumbnail: thumbnail)
                } ?? []
            }
        }
    }
}
// MARK: - Sample Data Arrays

//let topCategories: [Book2] = [
//    Book2(title: "Book 1", author: "Author 1", image: "Book", rating: 4.5),
//    Book2(title: "Book 2", author: "Author 2", image: "Book", rating: 4.2),
//    Book2(title: "Book 3", author: "Author 3", image: "Book", rating: 4.7),
//    Book2(title: "Book 4", author: "Author 4", image: "Book", rating: 4.0),
//    Book2(title: "Book 5", author: "Author 5", image: "Book", rating: 4.3)
//]

let topAuthors: [Author] = [
    Author(name: "Author A", image: "author1"),
    Author(name: "Author B", image: "author2"),
    Author(name: "Author C", image: "author3"),
    Author(name: "Author D", image: "author4"),
    Author(name: "Author E", image: "author5")
]
//
//let booksByAuthor: [String: [Book2]] = [
//    "Author A": [
//        Book2(title: "Book A1", author: "Author A", image: "Book", rating: 4.8),
//        Book2(title: "Book A2", author: "Author A", image: "Book", rating: 4.6),
//        Book2(title: "Book A3", author: "Author A", image: "Book", rating: 4.7)
//    ],
//    "Author B": [
//        Book2(title: "Book B1", author: "Author B", image: "Book", rating: 4.5),
//        Book2(title: "Book B2", author: "Author B", image: "Book", rating: 4.2)
//    ],
//    "Author C": [
//        Book2(title: "Book C1", author: "Author C", image: "Book", rating: 4.4),
//        Book2(title: "Book C2", author: "Author C", image: "Book", rating: 4.1),
//        Book2(title: "Book C3", author: "Author C", image: "Book", rating: 4.3),
//        Book2(title: "Book C4", author: "Author C", image: "Book", rating: 4.0)
//    ],
//    "Author D": [
//        Book2(title: "Book D1", author: "Author D", image: "Book", rating: 4.6),
//        Book2(title: "Book D2", author: "Author D", image: "Book", rating: 4.5)
//    ],
//    "Author E": [
//        Book2(title: "Book E1", author: "Author E", image: "Book", rating: 4.7),
//        Book2(title: "Book E2", author: "Author E", image: "Book", rating: 4.6),
//        Book2(title: "Book E3", author: "Author E", image: "Book", rating: 4.4)
//    ]
//]

// MARK: - Library View

// MARK: - Library View

struct LibraryView: View {
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(hex: "#ffffff"), Color(hex: "#f1d4cf")]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all) // Apply gradient background to whole screen

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        SearchBar()
                            .padding(.horizontal)
                            .padding(.top, 20)

                        TopCategoriesSection()
                            .padding(.horizontal)

//                        TopAuthorsSection(authors: topAuthors)
                            .padding(.horizontal)

                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Custom Views

struct SearchBar: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // Navigate back to HomeView
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.leading, 8) // Adjust left padding for space

                TextField("Search by title, topics and author", text: .constant(""))
                    .padding(.vertical, 12) // Increase vertical padding
                    .padding(.horizontal, 10) // Increase horizontal padding
                    .font(.body) // Adjust font size
                    .frame(height: 50) // Set a fixed height
                    .frame(maxWidth: .infinity) // Set the width to fill the available space
                    .background(Color.white) // Adjust background opacity
                    .cornerRadius(8)
                    .padding()
            }
            .padding(.horizontal, 20)
        }
    }
}

struct TopCategoriesSection: View {
    let categories = ["Fiction", "Fantasy", "Sci-Fi", "Self-Help", "Computers"]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Categories")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.top, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.flexible())], spacing: 20) {
                    ForEach(categories, id: \.self) { category in
                        NavigationLink(destination: BookListView(category: category)) {
                            CategoryCard(category: category)
                        }
                    }
                }
                .padding(.vertical, 10)
            }
        }
    }
}

struct CategoryCard: View {
    var category: String

    var body: some View {
        VStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.9))
                .frame(width: 130, height: 150)
                .overlay(
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category)
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                    }
                )
        }
    }
}

struct AuthorCard: View {
    var author: Author

    var body: some View {
        VStack {
            Image(author.image)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                )
            Text(author.name)
                .font(.headline)
                .foregroundColor(.black)
                .padding(.top, 8)
        }
    }
}

struct BookListView: View {
    @ObservedObject var firestoreManager = FirestoreManager()
    var category: String?
    var books: [Book2]?
    
    init(category: String) {
        self.category = category
        self.books = nil
        self.firestoreManager.fetchBooks(for: category)
    }
    
    init(books: [Book2]) {
        self.category = nil
        self.books = books
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#ffffff"), Color(hex: "#f1d4cf")]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all) // Apply gradient background to whole screen

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let books = books {
                        ForEach(books) { book in
                            HStack {
                                if let url = URL(string: book.thumbnail) {
                                    AsyncImage(url: url) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 80, height: 80)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        } else if phase.error != nil {
                                            Color.red // Indicates an error.
                                                .frame(width: 80, height: 80)
                                        } else {
                                            ProgressView()
                                                .frame(width: 80, height: 80)
                                        }
                                    }
                                } else {
                                    Color.gray // Placeholder color.
                                        .frame(width: 80, height: 80)
                                }
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(book.title)
                                        .font(.headline)
                                    Text(book.author)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Text("\(book.rating, specifier: "%.1f")")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(8)
                        }
                    } else {
                        ForEach(firestoreManager.books) { book in
                            HStack {
                                if let url = URL(string: book.thumbnail) {
                                    AsyncImage(url: url) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 80, height: 80)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        } else if phase.error != nil {
                                            Color.red // Indicates an error.
                                                .frame(width: 80, height: 80)
                                        } else {
                                            ProgressView()
                                                .frame(width: 80, height: 80)
                                        }
                                    }
                                } else {
                                    Color.gray // Placeholder color.
                                        .frame(width: 80, height: 80)
                                }
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(book.title)
                                        .font(.headline)
                                    Text(book.author)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Text("\(book.rating, specifier: "%.1f")")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitle(category ?? "Books", displayMode: .inline)
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
