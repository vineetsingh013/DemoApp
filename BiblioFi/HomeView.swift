import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Firebase

struct HomeView: View {
    @State private var isScaled = false
    @State private var showInfoCards = false
    @State private var booksdetails: [Book] = []
    @State private var recommendedBooks: [Book] = []
    @State private var showSideMenu = false
    @State private var showLibraryView = false
    @State private var showProfileView = false
    @State private var showScanner = false
    @State private var isSearching: Bool = false
    @State private var searchText: String = ""
    @State private var userCategories: [String] = []

    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                HStack {
                    NavigationLink(destination: NotificationsView()) {
                        Image("Oreo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: isScaled ? 400 : 150, height: isScaled ? 300 : 100)
//                            .onTapGesture {
//                                withAnimation {
//                                    isScaled.toggle()
//                                }
//                            }
                    }.buttonStyle(PlainButtonStyle())
                    Spacer()
                    
                    NavigationLink(destination: ProfileViewEE(), isActive: $showProfileView) {
                        Button(action: {
                            showProfileView.toggle()
                        }) {
                            Image(systemName: "person.circle")
                                .font(.title)
                                .foregroundColor(.black)
                                .padding()
                                .frame(width: 40, height: 40)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.trailing)
                }
                
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search by author, title, genre", text: $searchText)
                            .foregroundColor(.black)
                            .onTapGesture {
                                isSearching = true
                            }
                    }
                    .padding()
                    .background(Color(.white))
                    .cornerRadius(8)
                    
                    NavigationLink(
                        destination: LibraryView(),
                        isActive: $isSearching,
                        label: {
                            EmptyView()
                        }
                    )
                    .hidden()
                    
                    Button(action: {
                        showScanner.toggle()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .frame(width: 50, height: 50)
                                .shadow(radius: 3)
                            
                            Image(systemName: "barcode.viewfinder")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .sheet(isPresented: $showScanner) {
                        ScannerView()
                    }
                }
                
                if showInfoCards {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            InfoCard(title: "About BiblioFi", description: "BiblioFi is your go-to library management app.")
                            InfoCard(title: "Features", description: "Browse trending books, recommendations, and more.")
                            InfoCard(title: "Membership", description: "Become a member to unlock exclusive content.")
                        }
                        .padding(.horizontal)
                    }
                    .transition(.scale)
                }
                
                Text("Trending Books")
                    .font(.custom("Avenir Next Demi Bold", size: 30))
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(booksdetails) { book in
                            NavigationLink(destination: DetailView(book: book)) {
                                BookCard(book: book)
                            }
                            .frame(width: 280, height: 280)
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Text("Recommendations")
                                        .font(.custom("Avenir Next Demi Bold", size: 25))
                                        .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 20) {
                                            ForEach(recommendedBooks) { book in
                                                NavigationLink(destination: DetailView(book: book)) {
                                                    BookCardSmall(book: book)
                                                }
                                                .frame(width: 180, height: 210)
                                                .padding(.horizontal, 4)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    
                                    Text("Membership")
                                        .font(.custom("Avenir Next Demi Bold", size: 30))
                                        .padding(.horizontal)
                                    
                                    MembershipCard()
                                        .padding(.horizontal)
                                }
                            }
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color(hex: "#ffffff"), Color(hex: "#f1d4cf")]),
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing)
                                .edgesIgnoringSafeArea(.all)
                            )
                            .navigationBarHidden(true)
                            .onAppear {
                                fetchUserCategories { categories in
                                    self.userCategories = categories
                                    fetchBooks { allBooks in
                                        self.booksdetails = allBooks
                                        self.recommendedBooks = allBooks.filter { book in
                                            book.categories.contains { category in
                                                categories.contains(category)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    
            

    func fetchBooks(completion: @escaping ([Book]) -> Void) {
           let db = Firestore.firestore()
        db.collection("Books").addSnapshotListener { snapshot, error in
               if let error = error {
                   print("Error fetching books: \(error)")
                   completion([])
               } else {
                   var fetchedBooks: [Book] = []
                   for document in snapshot?.documents ?? [] {
                       let data = document.data()
                       let author = (data["authors"] as? [String])?.first ?? "Unknown Author"
                       let title = data["title"] as? String ?? "No Title"
                       let count = data["count"] as? String ?? "0"
                       let description = data["description"] as? String ?? "No Description"
                       let imageLinksData = data["imageLinks"] as? [String: String]
                       let imageLinks = imageLinksData.flatMap { ImageLinksCustom(thumbnail: $0["thumbnail"]) }
                       let rating = data["rating"] as? Double ?? 0.0
                       let categories = data["categories"] as? [String] ?? []
                       
                       let book = Book(id: document.documentID, title: title, author: author, count: count, description: description, imageLinks: imageLinks, categories: categories, rating: rating)
                       fetchedBooks.append(book)
                   }
                   completion(fetchedBooks)
               }
           }
       }
    
    func fetchUserCategories(completion: @escaping ([String]) -> Void) {
            guard let user = Auth.auth().currentUser else {
                completion([])
                return
            }

            let db = Firestore.firestore()
            db.collection("users").document(user.uid).getDocument { document, error in
                if let document = document, document.exists {
                    let data = document.data()
                    let categories = data?["preference"] as? [String] ?? []
                    completion(categories)
                } else {
                    completion([])
                }
            }
        }
    }

struct BookCard: View {
    let book: Book

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.3))
                .background(Blur(style: .systemMaterial))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 3)

            VStack {
                if let urlString = book.imageLinks?.thumbnail, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 180)
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }

                Text(book.title)
                    .font(.headline)
                    .foregroundColor(.black)

                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

struct BookCardSmall: View {
    let book: Book

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.3))
                .background(Blur(style: .systemMaterial))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 3)

            VStack {
                if let urlString = book.imageLinks?.thumbnail, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 120)
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }

                Text(book.title)
                    .font(.headline)
                    .foregroundColor(.black)

                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

struct MembershipCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.3))
                .background(Blur(style: .systemMaterial))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 3)
                .padding()

            VStack {
                Text("Become a Member")
                    .font(.title)
                    .foregroundColor(.black)
                    .padding()

                Text("Join our library to get exclusive access to more content and features.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()

                Button(action: {
                    // Action for membership button
                }) {
                    Text("Join Now")
                        .font(.headline)
                        .padding()
                        .background(Color(hex: "#8B551B"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding()
                }
            }
            .padding()
        }
    }
}

struct InfoCard: View {
    let title: String
    let description: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.3))
                .background(Blur(style: .systemMaterial))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 3)

            VStack {
                Text(title)
                    .font(.title)
                    .foregroundColor(.black)
                    .padding()

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .padding()
        }
    }
}

struct Book: Identifiable {
    @DocumentID var id: String?
    let title: String
    let author: String
    let count: String
    let description: String
    let imageLinks: ImageLinksCustom?
    let categories: [String]
    let rating: Double?
}

struct ImageLinksCustom {
    let thumbnail: String?
}



 struct DetailView: View {
     @State private var showConfirmationSheet = false
     @State private var statusMessage: String = ""
     @State private var availableCopies: Int = 0
     @State private var conversionMessage: String = ""
     var book: Book

     var body: some View {
         VStack {
             ScrollView {
                 // Book image and details
                 HStack(alignment: .top) {
                     if let urlString = book.imageLinks?.thumbnail, let url = URL(string: urlString) {
                         AsyncImage(url: url) { image in
                             image
                                 .resizable()
                                 .scaledToFit()
                                 .frame(width: 150, height: 180)
                         } placeholder: {
                             ProgressView()
                         }
                     } else {
                         Image(systemName: "photo")
                             .resizable()
                             .scaledToFit()
                             .frame(width: 50, height: 50)
                     }

                     VStack(alignment: .leading, spacing: 7) {
                         Text(book.title)
                             .font(.custom("AvenirNext-Bold", size: 30))
                             .fontWeight(.bold)

                         Text(book.author)
                             .font(.custom("AvenirNext-Regular", size: 15))
                             .foregroundColor(.gray)

                         HStack {
                             ForEach(0..<5) { index in
                                 Image(systemName: index < 4 ? "star.fill" : "star")
                                     .foregroundColor(.yellow)
                             }
                         }
                         Text(availableCopies > 0 ? "Available" : "Out of Stock")
                             .font(.custom("AvenirNext-Regular", size: 15))
                             .foregroundColor(availableCopies > 0 ? .green : .red)
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
                         Text(book.title)
                             .font(.custom("AvenirNext-Regular", size: 16))
                     }

                     HStack {
                         Text("Author: ")
                             .font(.custom("AvenirNext-Bold", size: 16))
                         Text(book.author)
                             .font(.custom("AvenirNext-Regular", size: 16))
                     }

                     HStack {
                         Text("Status: ")
                             .font(.custom("AvenirNext-Bold", size: 16))
                         Text(availableCopies > 0 ? "Available" : "Out of Stock")
                             .font(.custom("AvenirNext-Regular", size: 16))
                     }

                     HStack {
                         Text("Number of copies")
                             .font(.custom("AvenirNext-Bold", size: 16))
                         Text("\(availableCopies) available")
                             .font(.custom("AvenirNext-Regular", size: 16))
                     }

                     Text("Description: ")
                         .font(.custom("AvenirNext-Bold", size: 16))
                         .padding(.top, 1)

                     Text(book.description)
                         .font(.custom("AvenirNext-Regular", size: 16))
                 }
                 .padding()
             }

             // Checkout and Add to Cart buttons
             Divider()
             HStack {
                 Button(action: {
                     showConfirmationSheet = true
                 }) {
                     HStack {
                         Image(systemName: "cart")
                         Text("Issue Book")
                             .font(.custom("AvenirNext-Bold", size: 18))
                     }
                     .frame(maxWidth: .infinity)
                     .padding()
                     .background(Color(hex: "#945200"))
                     .foregroundColor(.white)
                     .cornerRadius(8)
                 }
                 .sheet(isPresented: $showConfirmationSheet) {
                     ConfirmationSheet(isPresented: $showConfirmationSheet, book: book, statusMessage: $statusMessage)
                 }

                 Button(action: {
                     // Action for the Add to Cart button
                 }) {
                     HStack {
                         Image(systemName: "bag")
                         Text("Place Hold")
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
         }
         .background(Color(hex: "#F9EDEA"))
         .onAppear {
             fetchAvailableCopies()
         }
     }

     func fetchAvailableCopies() {
         if let number = Int(book.count) {
             availableCopies = number
             conversionMessage = "Conversion successful"
         } else {
             availableCopies = -1
             conversionMessage = "Invalid number format"
         }
     }
 }

struct ConfirmationSheet: View {
    @Binding var isPresented: Bool
    var book: Book
    @Binding var statusMessage: String
    @State private var memberId: String = Auth.auth().currentUser?.uid ?? ""

    var body: some View {
        VStack(spacing: 20) {
            Text(book.title)
                .font(.custom("Avenir Next Bold", size: 24))
                .multilineTextAlignment(.center)
                .padding(.top)
            
            Text("Confirm your issue for '\(book.title)' by \(book.author)?")
                .font(.custom("Avenir Next Regular", size: 18))
                .multilineTextAlignment(.center)
                .padding()
            HStack(spacing: 20) {
                Button(action: fetchUserAndSendIssueRequest) {
                    
                    // Handle checkout logic
                    
                    Text("Confirm")
                        .font(.custom("Avenir Next Regular", size: 16))
                        .padding()
                        .frame(minWidth: 100)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    
                }
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .font(.custom("Avenir Next Regular", size: 16))
                        .padding()
                        .frame(minWidth: 100)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.bottom)
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.4)
        .background(Color(hex: "#F9EDEA")) // Replace with the custom color
        .cornerRadius(12)
        .shadow(radius: 10)

    }
    func fetchUserAndSendIssueRequest() {
        guard let user = Auth.auth().currentUser else {
            statusMessage = "User not authenticated"
            return
        }
        isPresented = false
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(user.uid)
        
        userDocRef.getDocument { document, error in
            if let document = document, document.exists {
                let userData = document.data()
                let memberName = userData?["fullName"] as? String ?? "Unknown"
                sendIssueRequest(memberName: memberName)
            } else {
                statusMessage = "User information not found"
            }
        }
    }


    func sendIssueRequest(memberName :String) {
        guard let user = Auth.auth().currentUser else {
            statusMessage = "User not authenticated"
            return
        }

        let db = Firestore.firestore()
        let request = Request(
            memberId: memberId,
            memberEmail: user.email ?? "unknown@example.com",
            memberName: memberName,
            bookId: book.id ?? UUID().uuidString,
            bookName: book.title,
            issueStatus: .pending,
            typeOfRequest: .issue,
            returnStatus: .pending,
            state: 0,
            timestamp: Timestamp(date: Date())
        )

        do {
            _ = try db.collection("requests").addDocument(from: request) { error in
                if let error = error {
                    statusMessage = "Error: \(error.localizedDescription)"
                } else {
                    updateBookCount()
                }
            }
        } catch {
            print("Error encoding request: \(error.localizedDescription)")
            statusMessage = "Error sending request"
        }
    }

    func updateBookCount() {
        let db = Firestore.firestore()
        let bookRef = db.collection("Books").document(book.id ?? UUID().uuidString)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let bookDocument: DocumentSnapshot
            do {
                try bookDocument = transaction.getDocument(bookRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            guard let oldCount = bookDocument.data()?["count"] as? Int else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve count from snapshot \(bookDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }

            transaction.updateData(["count": oldCount - 1], forDocument: bookRef)
            return nil
        }) { (object, error) in
            if let error = error {
                statusMessage = "Transaction failed: \(error.localizedDescription)"
            } else {
                statusMessage = "Request Sent"
            }
        }
    }
}


struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
