import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct Preference: View {
    @State private var selectedGenres: Set<String> = []
    @State private var genres: [String] = ["Fiction", "Non-Fiction", "Mystery", "Fantasy", "Sci-Fi", "Biography", "History", "Romance", "Horror", "Self-Help"]
    @State private var shouldNavigate: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Select Your Favorite Genres")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)

                Text("Select at least 3 genres")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)

                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                        ForEach(genres, id: \.self) { genre in
                            GenreButton(genre: genre, isSelected: selectedGenres.contains(genre)) {
                                if selectedGenres.contains(genre) {
                                    selectedGenres.remove(genre)
                                } else {
                                    selectedGenres.insert(genre)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                NavigationLink(destination: NewSwift().navigationBarBackButtonHidden(true), isActive: $shouldNavigate) {
                    EmptyView()
                }

                Button(action: {
                    savePreferences()
                }) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedGenres.count >= 3 ? Color(hex: "#945200") : Color.gray)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                }
                .disabled(selectedGenres.count < 3)
            }
            .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#ffffff"), Color(hex: "#f1d4cf")]),
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                            .edgesIgnoringSafeArea(.all))
            .navigationBarTitle("Genre Preferences", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
        }
    }

    func savePreferences() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user is logged in")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)

        userRef.setData(["preference": Array(selectedGenres)], merge: true) { error in
            if let error = error {
                print("Error saving preferences: \(error.localizedDescription)")
            } else {
                print("Preferences successfully saved!")
                shouldNavigate = true
            }
        }
    }
}

struct GenreButton: View {
    let genre: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(genre)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color(hex: "#945200") : Color.white)
                .foregroundColor(isSelected ? .white : .black)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color(hex: "#945200") : Color.gray, lineWidth: 0.5)
                )
        }
    }
}



struct PreferenceView_Previews: PreviewProvider {
    static var previews: some View {
        Preference()
    }
}
