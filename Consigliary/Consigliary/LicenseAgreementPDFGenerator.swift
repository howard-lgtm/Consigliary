import UIKit
import PDFKit

struct LicenseAgreementData {
    let trackName: String
    let platform: String
    let userName: String
    let licenseFee: Double
    let artistName: String
    let date: Date
}

class LicenseAgreementPDFGenerator {
    
    static func generatePDF(for license: LicenseAgreementData) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Consigliary",
            kCGPDFContextTitle: "License Agreement - \(license.trackName)",
            kCGPDFContextAuthor: license.artistName
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // US Letter size
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = 60
            let leftMargin: CGFloat = 50
            let rightMargin: CGFloat = pageWidth - 50
            let contentWidth = rightMargin - leftMargin
            
            // Header
            let headerFont = UIFont.systemFont(ofSize: 10, weight: .medium)
            let headerText = "CONSIGLIARY"
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: headerFont,
                .foregroundColor: UIColor.systemGreen
            ]
            headerText.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: headerAttributes)
            
            yPosition += 40
            
            // Title
            let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
            let titleText = "MUSIC LICENSE AGREEMENT"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.black
            ]
            titleText.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: titleAttributes)
            
            yPosition += 40
            
            // Divider
            let dividerPath = UIBezierPath()
            dividerPath.move(to: CGPoint(x: leftMargin, y: yPosition))
            dividerPath.addLine(to: CGPoint(x: rightMargin, y: yPosition))
            UIColor.systemGray3.setStroke()
            dividerPath.lineWidth = 1
            dividerPath.stroke()
            
            yPosition += 30
            
            // Agreement Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            
            let infoFont = UIFont.systemFont(ofSize: 11, weight: .regular)
            
            let dateText = "Agreement Date: \(dateFormatter.string(from: license.date))"
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: infoFont,
                .foregroundColor: UIColor.darkGray
            ]
            dateText.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: dateAttributes)
            
            yPosition += 30
            
            // Parties Section
            let sectionFont = UIFont.systemFont(ofSize: 14, weight: .bold)
            let sectionAttributes: [NSAttributedString.Key: Any] = [
                .font: sectionFont,
                .foregroundColor: UIColor.black
            ]
            
            "PARTIES".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 25
            
            let bodyFont = UIFont.systemFont(ofSize: 11, weight: .regular)
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: bodyFont,
                .foregroundColor: UIColor.darkGray
            ]
            
            let partiesText = """
            This License Agreement ("Agreement") is entered into between:
            
            LICENSOR: \(license.artistName) ("Artist")
            LICENSEE: \(license.userName) on \(license.platform) ("User")
            """
            
            let partiesRect = CGRect(x: leftMargin, y: yPosition, width: contentWidth, height: 80)
            partiesText.draw(in: partiesRect, withAttributes: bodyAttributes)
            
            yPosition += 90
            
            // Licensed Work Section
            "LICENSED WORK".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 25
            
            let workText = """
            Musical Composition: "\(license.trackName)"
            Platform: \(license.platform)
            License Fee: $\(String(format: "%.2f", license.licenseFee))
            """
            
            let workRect = CGRect(x: leftMargin, y: yPosition, width: contentWidth, height: 60)
            workText.draw(in: workRect, withAttributes: bodyAttributes)
            
            yPosition += 70
            
            // Grant of Rights
            "GRANT OF RIGHTS".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 25
            
            let rightsText = """
            The Artist hereby grants the User a non-exclusive, worldwide license to use the musical composition "\(license.trackName)" in content posted on \(license.platform). This license includes:
            
            • Synchronization rights for the specific content
            • Public performance rights for platform distribution
            • Reproduction rights as needed for platform functionality
            
            This license is perpetual for the specific content created, but does not grant rights for any additional uses beyond the original post.
            """
            
            let rightsRect = CGRect(x: leftMargin, y: yPosition, width: contentWidth, height: 130)
            rightsText.draw(in: rightsRect, withAttributes: bodyAttributes)
            
            yPosition += 140
            
            // Payment Terms
            "PAYMENT TERMS".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 25
            
            let paymentText = """
            The User agrees to pay the Artist a one-time license fee of $\(String(format: "%.2f", license.licenseFee)) USD. Payment is due within 30 days of this agreement. Upon receipt of payment, this license becomes active and binding.
            """
            
            let paymentRect = CGRect(x: leftMargin, y: yPosition, width: contentWidth, height: 60)
            paymentText.draw(in: paymentRect, withAttributes: bodyAttributes)
            
            yPosition += 70
            
            // Credit Requirements
            "CREDIT REQUIREMENTS".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 25
            
            let creditText = """
            The User agrees to provide appropriate credit to the Artist in the content description or caption, including the track title and artist name where reasonably possible.
            """
            
            let creditRect = CGRect(x: leftMargin, y: yPosition, width: contentWidth, height: 50)
            creditText.draw(in: creditRect, withAttributes: bodyAttributes)
            
            yPosition += 60
            
            // Signature Section
            yPosition = pageHeight - 220
            
            "SIGNATURES".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 35
            
            let signatureFont = UIFont.systemFont(ofSize: 10, weight: .regular)
            let signatureAttributes: [NSAttributedString.Key: Any] = [
                .font: signatureFont,
                .foregroundColor: UIColor.darkGray
            ]
            
            // Artist Signature Line
            let artistSigPath = UIBezierPath()
            artistSigPath.move(to: CGPoint(x: leftMargin, y: yPosition))
            artistSigPath.addLine(to: CGPoint(x: leftMargin + 250, y: yPosition))
            UIColor.black.setStroke()
            artistSigPath.lineWidth = 1
            artistSigPath.stroke()
            
            yPosition += 18
            
            "Artist: \(license.artistName)".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: signatureAttributes)
            
            // Date field aligned to the right
            let dateFieldText = "Date: _______________"
            let dateFieldSize = dateFieldText.size(withAttributes: signatureAttributes)
            dateFieldText.draw(at: CGPoint(x: rightMargin - dateFieldSize.width, y: yPosition), withAttributes: signatureAttributes)
            
            yPosition += 45
            
            // User Signature Line
            let userSigPath = UIBezierPath()
            userSigPath.move(to: CGPoint(x: leftMargin, y: yPosition))
            userSigPath.addLine(to: CGPoint(x: leftMargin + 250, y: yPosition))
            UIColor.black.setStroke()
            userSigPath.lineWidth = 1
            userSigPath.stroke()
            
            yPosition += 18
            
            "User: \(license.userName)".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: signatureAttributes)
            
            // Date field aligned to the right
            dateFieldText.draw(at: CGPoint(x: rightMargin - dateFieldSize.width, y: yPosition), withAttributes: signatureAttributes)
            
            // Footer
            yPosition = pageHeight - 60
            let footerText = "Generated by Consigliary • \(dateFormatter.string(from: Date()))"
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 8, weight: .regular),
                .foregroundColor: UIColor.systemGray
            ]
            
            let footerSize = footerText.size(withAttributes: footerAttributes)
            let footerX = (pageWidth - footerSize.width) / 2
            footerText.draw(at: CGPoint(x: footerX, y: yPosition), withAttributes: footerAttributes)
        }
        
        // Save to Documents directory
        let fileName = "\(license.trackName.replacingOccurrences(of: " ", with: "_"))_License_\(license.userName).pdf"
        
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Could not access documents directory")
            return nil
        }
        
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL, options: .atomic)
            
            // Set file attributes to ensure it's recognized as PDF
            try FileManager.default.setAttributes([.type: "com.adobe.pdf"], ofItemAtPath: fileURL.path)
            
            print("📄 PDF saved to Documents: \(fileURL.path)")
            return fileURL
        } catch {
            print("Error saving PDF: \(error)")
            return nil
        }
    }
}
