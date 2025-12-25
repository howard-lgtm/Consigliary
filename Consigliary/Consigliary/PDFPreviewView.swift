import SwiftUI
import PDFKit

struct PDFPreviewView: View {
    let pdfURL: URL
    @Environment(\.dismiss) var dismiss
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // PDF Preview using PDFKit
                PDFKitView(url: pdfURL)
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        onSave()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save & Complete License")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "32D74B"))
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.black)
            }
            .navigationTitle("License Agreement Preview")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = .white
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        if let document = PDFDocument(url: url) {
            pdfView.document = document
            print("📄 PDF loaded successfully: \(url.lastPathComponent)")
        } else {
            print("❌ Failed to load PDF from: \(url.path)")
        }
    }
}
