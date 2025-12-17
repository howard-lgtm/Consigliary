import UIKit
import PDFKit

class SplitSheetPDFGenerator {
    
    static func generatePDF(for splitSheet: SplitSheet) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Consigliary",
            kCGPDFContextTitle: "Split Sheet - \(splitSheet.track.title)",
            kCGPDFContextAuthor: "HTD Studio"
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
            
            // Header - Consigliary Logo/Title
            let headerFont = UIFont.systemFont(ofSize: 10, weight: .medium)
            let headerText = "CONSIGLIARY"
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: headerFont,
                .foregroundColor: UIColor.systemGreen
            ]
            headerText.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: headerAttributes)
            
            yPosition += 40
            
            // Main Title
            let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
            let titleText = "SPLIT SHEET AGREEMENT"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.black
            ]
            titleText.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: titleAttributes)
            
            yPosition += 50
            
            // Divider line
            let dividerPath = UIBezierPath()
            dividerPath.move(to: CGPoint(x: leftMargin, y: yPosition))
            dividerPath.addLine(to: CGPoint(x: rightMargin, y: yPosition))
            UIColor.systemGray3.setStroke()
            dividerPath.lineWidth = 1
            dividerPath.stroke()
            
            yPosition += 30
            
            // Track Information
            let infoFont = UIFont.systemFont(ofSize: 12, weight: .regular)
            let boldInfoFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
            
            let trackLabel = "Track Title:"
            let trackLabelAttributes: [NSAttributedString.Key: Any] = [
                .font: boldInfoFont,
                .foregroundColor: UIColor.black
            ]
            trackLabel.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: trackLabelAttributes)
            
            let trackValue = splitSheet.track.title
            let trackValueAttributes: [NSAttributedString.Key: Any] = [
                .font: infoFont,
                .foregroundColor: UIColor.darkGray
            ]
            trackValue.draw(at: CGPoint(x: leftMargin + 100, y: yPosition), withAttributes: trackValueAttributes)
            
            yPosition += 25
            
            let dateLabel = "Date Created:"
            dateLabel.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: trackLabelAttributes)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let dateValue = dateFormatter.string(from: Date())
            dateValue.draw(at: CGPoint(x: leftMargin + 100, y: yPosition), withAttributes: trackValueAttributes)
            
            yPosition += 40
            
            // Contributors Section
            let contributorsTitle = "CONTRIBUTORS"
            let contributorsTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            contributorsTitle.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: contributorsTitleAttributes)
            
            yPosition += 30
            
            // Table header
            let headerBgRect = CGRect(x: leftMargin, y: yPosition, width: contentWidth, height: 30)
            UIColor.systemGray6.setFill()
            UIBezierPath(rect: headerBgRect).fill()
            
            let tableHeaderFont = UIFont.systemFont(ofSize: 11, weight: .semibold)
            let tableHeaderAttributes: [NSAttributedString.Key: Any] = [
                .font: tableHeaderFont,
                .foregroundColor: UIColor.black
            ]
            
            // Column positions based on content width
            let col1X = leftMargin + 10  // #
            let col2X = leftMargin + 40  // Name
            let col3X = leftMargin + (contentWidth * 0.55)  // Role
            let col4X = leftMargin + (contentWidth * 0.80)  // Ownership %
            
            "#".draw(at: CGPoint(x: col1X, y: yPosition + 8), withAttributes: tableHeaderAttributes)
            "Name".draw(at: CGPoint(x: col2X, y: yPosition + 8), withAttributes: tableHeaderAttributes)
            "Role".draw(at: CGPoint(x: col3X, y: yPosition + 8), withAttributes: tableHeaderAttributes)
            "Ownership %".draw(at: CGPoint(x: col4X, y: yPosition + 8), withAttributes: tableHeaderAttributes)
            
            yPosition += 30
            
            // Contributors list
            let tableCellFont = UIFont.systemFont(ofSize: 11, weight: .regular)
            let tableCellAttributes: [NSAttributedString.Key: Any] = [
                .font: tableCellFont,
                .foregroundColor: UIColor.darkGray
            ]
            
            for (index, contributor) in splitSheet.contributors.enumerated() {
                // Alternating row background
                if index % 2 == 0 {
                    let rowRect = CGRect(x: leftMargin, y: yPosition, width: contentWidth, height: 25)
                    UIColor.systemGray6.withAlphaComponent(0.3).setFill()
                    UIBezierPath(rect: rowRect).fill()
                }
                
                "\(index + 1)".draw(at: CGPoint(x: col1X, y: yPosition + 5), withAttributes: tableCellAttributes)
                contributor.name.draw(at: CGPoint(x: col2X, y: yPosition + 5), withAttributes: tableCellAttributes)
                (contributor.role ?? "Contributor").draw(at: CGPoint(x: col3X, y: yPosition + 5), withAttributes: tableCellAttributes)
                "\(Int(contributor.splitPercentage))%".draw(at: CGPoint(x: col4X, y: yPosition + 5), withAttributes: tableCellAttributes)
                
                yPosition += 25
            }
            
            yPosition += 20
            
            // Total
            let totalRect = CGRect(x: leftMargin, y: yPosition, width: contentWidth, height: 30)
            UIColor.systemGreen.withAlphaComponent(0.1).setFill()
            UIBezierPath(rect: totalRect).fill()
            
            let totalFont = UIFont.systemFont(ofSize: 14, weight: .bold)
            let totalAttributes: [NSAttributedString.Key: Any] = [
                .font: totalFont,
                .foregroundColor: UIColor.systemGreen
            ]
            
            let totalPercentage = splitSheet.contributors.reduce(0.0) { $0 + $1.splitPercentage }
            "TOTAL:".draw(at: CGPoint(x: col1X, y: yPosition + 8), withAttributes: totalAttributes)
            "\(totalPercentage)%".draw(at: CGPoint(x: col4X, y: yPosition + 8), withAttributes: totalAttributes)
            
            yPosition += 60
            
            // Agreement Text
            let agreementText = """
            This split sheet confirms the ownership percentages for the musical composition titled "\(splitSheet.track.title)". \
            All contributors listed above agree to these ownership percentages and understand that this document serves as \
            a binding agreement for the distribution of royalties and rights.
            """
            
            let agreementFont = UIFont.systemFont(ofSize: 10, weight: .regular)
            let agreementAttributes: [NSAttributedString.Key: Any] = [
                .font: agreementFont,
                .foregroundColor: UIColor.darkGray
            ]
            
            let agreementRect = CGRect(x: leftMargin, y: yPosition, width: contentWidth, height: 100)
            agreementText.draw(in: agreementRect, withAttributes: agreementAttributes)
            
            yPosition += 100
            
            // Signature Section
            yPosition += 40
            let signaturesTitle = "SIGNATURES"
            signaturesTitle.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: contributorsTitleAttributes)
            
            yPosition += 40
            
            let signatureFont = UIFont.systemFont(ofSize: 10, weight: .regular)
            let signatureAttributes: [NSAttributedString.Key: Any] = [
                .font: signatureFont,
                .foregroundColor: UIColor.darkGray
            ]
            
            for contributor in splitSheet.contributors {
                // Signature line
                let signaturePath = UIBezierPath()
                signaturePath.move(to: CGPoint(x: leftMargin, y: yPosition))
                signaturePath.addLine(to: CGPoint(x: leftMargin + (contentWidth * 0.45), y: yPosition))
                UIColor.black.setStroke()
                signaturePath.lineWidth = 1
                signaturePath.stroke()
                
                yPosition += 15
                
                contributor.name.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: signatureAttributes)
                
                let dateSignature = "Date: _______________"
                dateSignature.draw(at: CGPoint(x: leftMargin + (contentWidth * 0.55), y: yPosition), withAttributes: signatureAttributes)
                
                yPosition += 50
            }
            
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
        
        // Save to temporary directory
        let fileName = "\(splitSheet.track.title.replacingOccurrences(of: " ", with: "_"))_SplitSheet.pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Error saving PDF: \(error)")
            return nil
        }
    }
}
