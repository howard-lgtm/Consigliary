import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appData: AppData
    @Environment(\.dismiss) var dismiss
    
    @State private var name = "Howard Duffy"
    @State private var email = "howard@htdstudio.net"
    @State private var artistType = "Independent Artist"
    @State private var genre = "Electronic"
    @State private var showingSaveAlert = false
    
    let artistTypes = ["Independent Artist", "Signed Artist", "Producer", "Label", "Manager"]
    let genres = ["Electronic", "Hip Hop", "Pop", "Rock", "R&B", "Country", "Jazz", "Classical", "Other"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Photo
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "32D74B"))
                                .frame(width: 100, height: 100)
                            
                            Text("HD")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.black)
                        }
                        
                        Button(action: {
                            // Photo picker would go here
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
                        let notification = UINotificationFeedbackGenerator()
                        notification.notificationOccurred(.success)
                        showingSaveAlert = true
                    }) {
                        Text("Save Changes")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "32D74B"))
                            .cornerRadius(12)
                    }
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
