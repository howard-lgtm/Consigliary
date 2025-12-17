import SwiftUI

struct AudioUploadSheet: View {
    let trackTitle: String
    @Binding var selectedAudioURL: URL?
    @Binding var isUploading: Bool
    let onUpload: () -> Void
    let onSkip: () -> Void
    
    @State private var showingAudioPicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
                // Icon
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "64D2FF"))
                
                // Title
                VStack(spacing: 8) {
                    Text("Upload Audio File")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("For \"\(trackTitle)\"")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Description
                Text("Upload an audio file to enable fingerprinting and verification. This helps protect your track from unauthorized use.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Selected file
                if let audioURL = selectedAudioURL {
                    HStack {
                        Image(systemName: "music.note")
                            .foregroundColor(Color(hex: "32D74B"))
                        Text(audioURL.lastPathComponent)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            selectedAudioURL = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(hex: "1C1C1E"))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Buttons
                VStack(spacing: 12) {
                    if selectedAudioURL == nil {
                        Button(action: {
                            showingAudioPicker = true
                        }) {
                            HStack {
                                Image(systemName: "folder.badge.plus")
                                Text("Choose Audio File")
                            }
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "64D2FF"))
                            .cornerRadius(12)
                        }
                    } else {
                        Button(action: onUpload) {
                            HStack {
                                if isUploading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Image(systemName: "arrow.up.circle.fill")
                                    Text("Upload & Fingerprint")
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "32D74B"))
                            .cornerRadius(12)
                        }
                        .disabled(isUploading)
                    }
                    
                    Button(action: onSkip) {
                        Text("Skip for Now")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "1C1C1E"))
                            .cornerRadius(12)
                    }
                    .disabled(isUploading)
                }
                .padding()
            }
            .background(Color.black)
            .navigationTitle("Audio Upload")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAudioPicker) {
                AudioPickerView(audioURL: $selectedAudioURL)
            }
        }
    }
}
