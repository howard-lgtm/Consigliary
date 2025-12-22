import SwiftUI
import UniformTypeIdentifiers

struct AudioPickerView: UIViewControllerRepresentable {
    @Binding var audioURL: URL?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [
                UTType.audio,
                UTType.mp3,
                UTType(filenameExtension: "m4a")!,
                UTType(filenameExtension: "wav")!,
                UTType(filenameExtension: "aac")!
            ],
            asCopy: true
        )
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: AudioPickerView
        
        init(_ parent: AudioPickerView) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            // Use centralized iCloud file handler
            iCloudFileHandler.shared.prepareFile(at: url) { preparedURL in
                DispatchQueue.main.async {
                    if let preparedURL = preparedURL {
                        self.parent.audioURL = preparedURL
                        print("✅ Audio file ready: \(preparedURL.lastPathComponent)")
                    } else {
                        print("❌ Failed to prepare audio file")
                    }
                }
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.audioURL = nil
        }
    }
}
