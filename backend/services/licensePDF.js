const PDFDocument = require('pdfkit');
const fs = require('fs');
const path = require('path');
const os = require('os');

class LicensePDFGenerator {
  /**
   * Generate a professional license agreement PDF
   * @param {Object} licenseData - License information
   * @returns {Promise<Buffer>} PDF buffer
   */
  async generateLicensePDF(licenseData) {
    return new Promise((resolve, reject) => {
      try {
        const doc = new PDFDocument({
          size: 'LETTER',
          margins: { top: 50, bottom: 50, left: 50, right: 50 }
        });

        const chunks = [];
        doc.on('data', chunk => chunks.push(chunk));
        doc.on('end', () => resolve(Buffer.concat(chunks)));
        doc.on('error', reject);

        // Header
        this.addHeader(doc, licenseData);
        
        // License Details
        this.addLicenseDetails(doc, licenseData);
        
        // Terms and Conditions
        this.addTermsAndConditions(doc, licenseData);
        
        // Payment Information
        this.addPaymentInformation(doc, licenseData);
        
        // Signature Section
        this.addSignatureSection(doc, licenseData);
        
        // Footer
        this.addFooter(doc, licenseData);

        doc.end();
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * Add header to PDF
   */
  addHeader(doc, data) {
    doc.fontSize(24)
       .font('Helvetica-Bold')
       .text('MUSIC LICENSE AGREEMENT', { align: 'center' })
       .moveDown();

    doc.fontSize(10)
       .font('Helvetica')
       .text(`License ID: ${data.licenseId}`, { align: 'center' })
       .text(`Date: ${new Date(data.createdAt).toLocaleDateString()}`, { align: 'center' })
       .moveDown(2);
  }

  /**
   * Add license details section
   */
  addLicenseDetails(doc, data) {
    doc.fontSize(14)
       .font('Helvetica-Bold')
       .text('LICENSE DETAILS')
       .moveDown(0.5);

    doc.fontSize(10)
       .font('Helvetica');

    // Licensor (Rights Holder)
    doc.font('Helvetica-Bold').text('Licensor (Rights Holder):');
    doc.font('Helvetica')
       .text(`Name: ${data.licensorName}`)
       .text(`Email: ${data.licensorEmail}`)
       .moveDown();

    // Licensee (User)
    doc.font('Helvetica-Bold').text('Licensee (User):');
    doc.font('Helvetica')
       .text(`Name: ${data.licenseeName || 'Not Provided'}`)
       .text(`Email: ${data.licenseeEmail}`)
       .text(`Platform: ${data.licenseePlatform}`)
       .text(`Channel: ${data.licenseeChannelUrl || 'Not Provided'}`)
       .moveDown();

    // Licensed Work
    doc.font('Helvetica-Bold').text('Licensed Musical Work:');
    doc.font('Helvetica')
       .text(`Title: ${data.trackTitle}`)
       .text(`Artist: ${data.trackArtist}`)
       .text(`Copyright Owner: ${data.copyrightOwner || data.licensorName}`)
       .text(`Copyright Year: ${data.copyrightYear || 'N/A'}`)
       .moveDown();

    // Usage Details
    doc.font('Helvetica-Bold').text('Unauthorized Usage Detected:');
    doc.font('Helvetica')
       .text(`Video URL: ${data.videoUrl}`)
       .text(`Video Title: ${data.videoTitle || 'N/A'}`)
       .text(`Platform: ${data.platform}`)
       .text(`Views: ${data.viewCount ? data.viewCount.toLocaleString() : 'N/A'}`)
       .moveDown(2);
  }

  /**
   * Add terms and conditions
   */
  addTermsAndConditions(doc, data) {
    doc.fontSize(14)
       .font('Helvetica-Bold')
       .text('LICENSE TERMS')
       .moveDown(0.5);

    doc.fontSize(10)
       .font('Helvetica');

    // License Grant
    doc.font('Helvetica-Bold').text('1. License Grant');
    doc.font('Helvetica')
       .text(`The Licensor grants the Licensee a ${data.exclusivity || 'non-exclusive'}, ` +
             `${data.duration || 'perpetual'} license to use the musical work "${data.trackTitle}" ` +
             `in the video located at ${data.videoUrl}.`)
       .moveDown();

    // Territory
    doc.font('Helvetica-Bold').text('2. Territory');
    doc.font('Helvetica')
       .text(`This license is valid for: ${data.territory || 'Worldwide'}`)
       .moveDown();

    // License Fee
    doc.font('Helvetica-Bold').text('3. License Fee');
    doc.font('Helvetica')
       .text(`The Licensee agrees to pay a one-time license fee of ${data.currency || 'USD'} ` +
             `$${data.licenseFee.toFixed(2)} for the use of the musical work.`)
       .moveDown();

    // Permitted Use
    doc.font('Helvetica-Bold').text('4. Permitted Use');
    doc.font('Helvetica')
       .text('The Licensee may use the musical work solely in the specified video. ' +
             'This license does not grant rights to use the work in any other videos, ' +
             'projects, or media without obtaining additional licenses.')
       .moveDown();

    // Restrictions
    doc.font('Helvetica-Bold').text('5. Restrictions');
    doc.font('Helvetica')
       .text('The Licensee may not:')
       .list([
         'Claim ownership of the musical work',
         'Sublicense or transfer this license to third parties',
         'Use the work in a manner that is defamatory, obscene, or illegal',
         'Remove or alter any copyright notices or attributions'
       ])
       .moveDown();

    // Attribution
    doc.font('Helvetica-Bold').text('6. Attribution');
    doc.font('Helvetica')
       .text(`The Licensee must provide proper attribution: "${data.trackTitle}" by ${data.trackArtist}`)
       .moveDown();

    // Payment Terms
    doc.font('Helvetica-Bold').text('7. Payment Terms');
    doc.font('Helvetica')
       .text('Payment must be received within 14 days of this agreement. ' +
             'Failure to pay may result in license termination and legal action.')
       .moveDown(2);
  }

  /**
   * Add payment information
   */
  addPaymentInformation(doc, data) {
    // Add new page if needed
    if (doc.y > 650) {
      doc.addPage();
    }

    doc.fontSize(14)
       .font('Helvetica-Bold')
       .text('PAYMENT INFORMATION')
       .moveDown(0.5);

    doc.fontSize(10)
       .font('Helvetica');

    doc.text(`License Fee: ${data.currency || 'USD'} $${data.licenseFee.toFixed(2)}`)
       .text(`Payment Due: ${new Date(Date.now() + 14 * 24 * 60 * 60 * 1000).toLocaleDateString()}`)
       .moveDown();

    if (data.paymentLink) {
      doc.font('Helvetica-Bold').text('Payment Link:');
      doc.font('Helvetica')
         .fillColor('blue')
         .text(data.paymentLink, { link: data.paymentLink, underline: true })
         .fillColor('black')
         .moveDown();
    }

    doc.text('Payment can be made via the provided link or by contacting the licensor directly.')
       .moveDown(2);
  }

  /**
   * Add signature section
   */
  addSignatureSection(doc, data) {
    // Add new page if needed
    if (doc.y > 600) {
      doc.addPage();
    }

    doc.fontSize(14)
       .font('Helvetica-Bold')
       .text('SIGNATURES')
       .moveDown(0.5);

    doc.fontSize(10)
       .font('Helvetica');

    // Licensor signature
    doc.text('Licensor (Rights Holder):')
       .moveDown(0.5);
    
    doc.text(`Name: ${data.licensorName}`)
       .moveDown(2);
    
    doc.text('_'.repeat(50))
       .text('Signature', { continued: true })
       .text(`Date: ${new Date().toLocaleDateString()}`, { align: 'right' })
       .moveDown(2);

    // Licensee signature
    doc.text('Licensee (User):')
       .moveDown(0.5);
    
    doc.text(`Name: ${data.licenseeName || data.licenseeEmail}`)
       .moveDown(2);
    
    doc.text('_'.repeat(50))
       .text('Signature', { continued: true })
       .text('Date: _______________', { align: 'right' })
       .moveDown(2);
  }

  /**
   * Add footer
   */
  addFooter(doc, data) {
    const bottomMargin = 50;
    const pageHeight = doc.page.height;
    
    doc.fontSize(8)
       .font('Helvetica')
       .text(
         'This is a legally binding agreement. By accepting payment or using the licensed work, ' +
         'the Licensee agrees to all terms and conditions outlined in this document.',
         50,
         pageHeight - bottomMargin - 30,
         { align: 'center', width: doc.page.width - 100 }
       );

    doc.text(
      `Generated by Consigliary • ${new Date().toLocaleDateString()}`,
      50,
      pageHeight - bottomMargin - 10,
      { align: 'center', width: doc.page.width - 100 }
    );
  }
}

module.exports = new LicensePDFGenerator();
