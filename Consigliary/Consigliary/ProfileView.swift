import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var artistName = ""
    @State private var artistType = "Independent Artist"
    @State private var genre = "Electronic"
    @State private var showingSaveAlert = false
    @State private var showingImagePicker = false
    @State private var profileImage: UIImage?
    @State private var hasChanges = false
    
    let artistTypes = ["Independent Artist", "Signed Artist", "Producer", "Label", "Manager"]
    let genres = ["Electronic", "Hip Hop", "Pop", "Rock", "R&B", "Country", "Jazz", "Classical", "Other"]
    
    var body: some View {
        ScrollView {
                VStack(spacing: 24) {
                    // Profile Photo
                    VStack(spacing: 16) {
                        ZStack {
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color(hex: "32D74B"))
                                    .frame(width: 100, height: 100)
                                
                                Text(appState.currentUser?.initials ?? "?")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }
                        
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Text("Change Photo")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "64D2FF"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    
                    // Form Fields
                    VStack(spacing: 20) {
                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            TextField("Name", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                                .onChange(of: name) { _ in hasChanges = true }
                        }
                        
                        // Artist Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Artist Name")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            TextField("Artist Name", text: $artistName)
                                .textFieldStyle(CustomTextFieldStyle())
                                .onChange(of: artistName) { _ in hasChanges = true }
                        }
                        
                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            TextField("Email", text: $email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .onChange(of: email) { _ in hasChanges = true }
                        }
                        
                        // Artist Type
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Artist Type")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Menu {
                                ForEach(artistTypes, id: \.self) { type in
                                    Button(type) {
                                        artistType = type
                                        hasChanges = true
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(artistType)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                .padding()
                                .background(Color(hex: "1C1C1E"))
                                .cornerRadius(12)
                            }
                        }
                        
                        // Genre
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Primary Genre")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Menu {
                                ForEach(genres, id: \.self) { genreOption in
                                    Button(genreOption) {
                                        genre = genreOption
                                        hasChanges = true
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(genre)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                .padding()
                                .background(Color(hex: "1C1C1E"))
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    // Save Button
                    Button(action: {
                        saveProfile()
                    }) {
                        Text("Save Changes")
                            .font(.headline)
                            .foregroundColor(hasChanges ? .black : .gray)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(hasChanges ? Color(hex: "32D74B") : Color.gray.opacity(0.3))
                            .cornerRadius(12)
                    }
                    .disabled(!hasChanges)
                    .padding(.top, 20)
                }
                .padding()
            }
            .background(Color.black)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Profile Updated", isPresented: $showingSaveAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your profile has been successfully updated.")
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $profileImage)
            }
            .onAppear {
                loadUserData()
            }
            .onChange(of: profileImage) { _ in
                hasChanges = true
            }
    }
    
    private func loadUserData() {
        guard let user = appState.currentUser else { return }
        name = user.name
        email = user.email
        artistName = user.artistName
        artistType = user.artistType ?? "Independent Artist"
        genre = user.genre ?? "Electronic"
        
        if let imageData = user.profileImageData {
            profileImage = UIImage(data: imageData)
        }
    }
    
    private func saveProfile() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
        
        // Save to AppState (persists to UserDefaults)
        appState.updateUser(
            name: name,
            email: email,
            artistName: artistName,
            artistType: artistType,
            genre: genre,
            profileImageData: profileImage?.jpegData(compressionQuality: 0.8)
        )
        
        hasChanges = false
        showingSaveAlert = true
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(hex: "1C1C1E"))
            .cornerRadius(12)
            .foregroundColor(.white)
    }
}
