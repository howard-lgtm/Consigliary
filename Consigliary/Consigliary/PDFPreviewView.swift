import SwiftUI
import WebKit

struct PDFPreviewView: View {
    let pdfURL: URL
    @Environment(\.dismiss) var dismiss
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // PDF Preview using WebView
                WebViewPDF(url: pdfURL)
                
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

struct WebViewPDF: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .white
        webView.isOpaque = false
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
        print("📄 Loading PDF in WebView: \(url.lastPathComponent)")
    }
}
