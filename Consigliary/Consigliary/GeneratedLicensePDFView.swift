import SwiftUI
import PDFKit

struct GeneratedLicensePDFView: View {
    let pdfURL: URL
    @Environment(\.dismiss) var dismiss
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // PDF Preview
                PDFKitRepresentable(url: pdfURL)
                    .edgesIgnoringSafeArea(.top)
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share License Agreement")
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
                        Text("Done")
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
            .navigationTitle("License Agreement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Color(hex: "32D74B"))
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [pdfURL])
        }
    }
}

struct PDFKitRepresentable: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = .systemBackground
        
        // Load PDF document
        if let document = PDFDocument(url: url) {
            pdfView.document = document
            print("✅ PDF loaded successfully: \(url.lastPathComponent)")
            print("📄 Page count: \(document.pageCount)")
        } else {
            print("❌ Failed to load PDF from: \(url.path)")
            print("📂 File exists: \(FileManager.default.fileExists(atPath: url.path))")
        }
        
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        // Only load if document is nil
        if pdfView.document == nil {
            if let document = PDFDocument(url: url) {
                pdfView.document = document
                print("✅ PDF reloaded: \(url.lastPathComponent)")
            }
        }
    }
}
