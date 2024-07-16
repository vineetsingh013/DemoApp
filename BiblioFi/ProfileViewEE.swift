import SwiftUI
import Firebase
import FirebaseStorage
import PhotosUI

struct ProfileViewEE: View {
    @State private var isLoggedIn = true // Example state to simulate login/logout
    @State private var showEditProfile = false
    @State private var showFine = false
    @State private var showImagePicker = false
    @State private var showImageSourceActionSheet = false
    @State private var showImageCropper = false
    @State private var profileImage: UIImage?
    @State private var selectedImage: UIImage?
    @State private var fullName: String = "Loading..."
    @State private var phoneNumber: String = ""
    @State private var userId: String?
    @State private var showLogoutConfirmation = false // New state for showing logout confirmation

    @State private var navigateToLogin = false // New state for navigation to login page

    var body: some View {
        NavigationView {
            VStack {
                // Profile Image and Name
                if let profileImage = profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .padding(.top, 20)
                        .onTapGesture {
                            showImageSourceActionSheet = true
                        }
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .padding(.top, 20)
                        .onTapGesture {
                            showImageSourceActionSheet = true
                        }
                }

                Text(fullName)
                    .font(.title)
                    .padding(.bottom, 10)

                // Settings and Support Sections in a List
                List {
                    Section(header: Text("Profile").font(.headline)) {
                        Button(action: {
                            showEditProfile.toggle() // Show the edit profile sheet
                        }) {
                            HStack {
                                Image(systemName: "person.circle")
                                Text("Profile")
                            }
                        }
                        .sheet(isPresented: $showEditProfile) {
                            EditProfileView()
                        }
                        NavigationLink(destination: Text("Wishlist")) {
                            HStack {
                                Image(systemName: "heart.circle")
                                Text("Wishlist")
                            }
                        }
                        Button(action: {
                            showFine.toggle() // Show the edit profile sheet
                        }) {
                            HStack {
                                Image(systemName: "person.circle")
                                Text("Fine")
                            }
                        }
                        .sheet(isPresented: $showFine) {
                            FineDetail()
                        }
                        NavigationLink(destination: Text("Borrowing History")) {
                            HStack {
                                Image(systemName: "clock.circle")
                                Text("History")
                            }
                        }
                    }

                    Section(header: Text("Support").font(.headline)) {
                        NavigationLink(destination: Text("About Us")) {
                            HStack {
                                Image(systemName: "info.circle")
                                Text("About Us")
                            }
                        }
                        NavigationLink(destination: Text("FAQ")) {
                            HStack {
                                Image(systemName: "questionmark.circle")
                                Text("FAQ")
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())

                // Log Out Button
                Button(action: {
                    showLogoutConfirmation.toggle()
                }) {
                    Text("Log Out")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .padding(.vertical, 20)
                .popover(isPresented: $showLogoutConfirmation, arrowEdge: .bottom) {
                    VStack {
                        Text("Are you sure you want to log out?")
                            .font(.headline)
                            .padding()
                        HStack {
                            Button(action: {
                                showLogoutConfirmation = false
                            }) {
                                Text("Cancel")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                            }
                            Button(action: {
                                handleLogout()
                            }) {
                                Text("Log Out")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding()
                }

                Spacer()
            }
            .navigationBarTitle("Profile", displayMode: .inline)
            .onAppear {
                fetchUserProfile()
            }
            .actionSheet(isPresented: $showImageSourceActionSheet) {
                ActionSheet(title: Text("Select Image Source"), buttons: [
                    .default(Text("Camera")) {
                        showImagePicker = true
                    },
                    .default(Text("Gallery")) {
                        showImagePicker = true
                    },
                    .cancel()
                ])
            }
            .sheet(isPresented: $showImagePicker, onDismiss: {
                if selectedImage != nil {
                    showImageCropper = true
                }
            }) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .sheet(isPresented: $showImageCropper, onDismiss: {
                if let croppedImage = selectedImage {
                    profileImage = croppedImage
                    uploadProfileImage(image: croppedImage)
                }
            }) {
                ImageCropper(image: $selectedImage, isPresented: $showImageCropper)
            }
            .background(
                NavigationLink(destination: LoginPage().navigationBarBackButtonHidden(true), isActive: $navigateToLogin) {
                    EmptyView()
                }
            )
        }
    }

    func fetchUserProfile() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is logged in")
            return
        }
        userId = currentUser.uid

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId!)

        userRef.addSnapshotListener { document, error in
            if let error = error {
                print("Error fetching document: \(error)")
                fullName = "Error fetching name"
                return
            }

            if let document = document, document.exists {
                print("Document data: \(document.data() ?? [:])")
                let firstName = document.get("firstName") as? String ?? "No"
                let lastName = document.get("lastName") as? String ?? "Name"
                fullName = "\(firstName) \(lastName)"
                phoneNumber = document.get("phoneNumber") as? String ?? ""
                if let profileImageUrl = document.get("profilepicture") as? String {
                    loadImage(from: profileImageUrl) { image in
                        self.profileImage = image
                    }
                }
            } else {
                print("Document does not exist")
                fullName = "Document does not exist"
            }
        }
    }

    func uploadProfileImage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        guard let userId = userId else { return }

        let storage = Storage.storage()
        let storageRef = storage.reference().child("profile_images/\(userId).jpg")

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil else {
                print("Failed to upload image")
                return
            }

            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    print("Failed to get download URL")
                    return
                }

                let db = Firestore.firestore()
                let userRef = db.collection("users").document(userId)

                userRef.updateData(["profilepicture": downloadURL.absoluteString]) { error in
                    if let error = error {
                        print("Failed to update user profile picture: \(error)")
                    } else {
                        fetchUserProfile()
                    }
                }
            }
        }
    }

    func loadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        guard let imageURL = URL(string: url) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }

    func handleLogout() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            showLogoutConfirmation = false
            navigateToLogin = true
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType = .photoLibrary

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var selectedImage: UIImage?

        init(selectedImage: Binding<UIImage?>) {
            _selectedImage = selectedImage
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                selectedImage = image
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(selectedImage: $selectedImage)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct ImageCropper: View {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool

    @State private var croppedImage: UIImage?

    var body: some View {
        VStack {
            if let image = image {
                GeometryReader { geometry in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                }
                .padding()
            }
            Button("Done") {
                croppedImage = image?.cropToCircle()
                if let croppedImage = croppedImage {
                    image = croppedImage
                }
                // Dismiss the view
                isPresented = false
            }
            .padding()
        }
    }
}

extension UIImage {
    func cropToCircle() -> UIImage? {
        let shortestSide = min(size.width, size.height)
        let square = CGRect(x: (size.width - shortestSide) / 2, y: (size.height - shortestSide) / 2, width: shortestSide, height: shortestSide)

        guard let cgImage = cgImage?.cropping(to: square) else { return nil }

        let circleImage = UIImage(cgImage: cgImage).withRoundedCorners(radius: shortestSide / 2)
        return circleImage
    }

    func withRoundedCorners(radius: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(roundedRect: rect, cornerRadius: radius).addClip()
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
