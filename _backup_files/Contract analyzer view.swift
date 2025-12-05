import SwiftUI

struct ContractAnalyzerView: View {
    @State private var selectedScenario: ContractAnalysis?
    @State private var isAnalyzing = false
    @State private var showingScenarioPicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if selectedScenario == nil {
                    // Upload Section
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("AI Contract Analyzer")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Upload your contract and get instant AI-powered analysis")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Upload Area
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(Color(hex: "64D2FF"))
                            
                            Text("Drop your contract here")
                                .font(.headline)
                            
                            Text("PDF, DOC, or DOCX • Max 10MB")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Button(action: {}) {
                                Text("Choose File")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "64D2FF"))
                                    .cornerRadius(8)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(40)
                        .background(Color(hex: "1C1C1E"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "64D2FF").opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [10]))
                        )
                        
                        // Demo Scenarios
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Try Demo Analysis")
                                .font(.headline)
                            
                            Text("See how our AI analyzes different contract types")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            ForEach(ContractAnalysis.demoScenarios) { scenario in
                                Button(action: {
                                    isAnalyzing = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        isAnalyzing = false
                                        selectedScenario = scenario
                                    }
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(scenario.contractName)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text(scenario.contractType)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        // Score preview
                                        HStack(spacing: 4) {
                                            Text(String(format: "%.1f", scenario.fairnessScore))
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .foregroundColor(scoreColor(scenario.fairnessScore))
                                            Text("/10")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                    .padding()
                                    .background(Color(hex: "1C1C1E"))
                                    .cornerRadius(12)
                                }
                                .disabled(isAnalyzing)
                            }
                        }
                        
                        // Features
                        VStack(alignment: .leading, spacing: 16) {
                            Text("What We Analyze")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            FeatureItem(
                                icon: "checkmark.shield.fill",
                                title: "Fairness Score",
                                description: "Overall contract fairness rating (1-10)",
                                color: Color(hex: "32D74B")
                            )
                            
                            FeatureItem(
                                icon: "exclamationmark.triangle.fill",
                                title: "Red Flags",
                                description: "Problematic clauses and unfair terms",
                                color: Color(hex: "FF453A")
                            )
                            
                            FeatureItem(
                                icon: "lightbulb.fill",
                                title: "Recommendations",
                                description: "Suggested improvements and negotiations",
                                color: Color(hex: "FFD60A")
                            )
                            
                            FeatureItem(
                                icon: "doc.text.fill",
                                title: "Plain English",
                                description: "Complex legal terms explained simply",
                                color: Color(hex: "64D2FF")
                            )
                        }
                    }
                } else if let analysis = selectedScenario {
                    // Analysis Results
                    VStack(spacing: 24) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Analysis Complete")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(analysis.contractName)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                selectedScenario = nil
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.title2)
                            }
                        }
                        
                        // Fairness Score
                        VStack(spacing: 12) {
                            Text("Fairness Score")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                                    .frame(width: 150, height: 150)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(analysis.fairnessScore / 10))
                                    .stroke(scoreColor(analysis.fairnessScore), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                    .frame(width: 150, height: 150)
                                    .rotationEffect(.degrees(-90))
                                
                                VStack(spacing: 4) {
                                    Text(String(format: "%.1f", analysis.fairnessScore))
                                        .font(.system(size: 48, weight: .bold))
                                    Text("out of 10")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Text(analysis.scoreCategory)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(scoreColor(analysis.fairnessScore))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "1C1C1E"))
                        .cornerRadius(12)
                        
                        // Key Terms
                        if !analysis.keyTerms.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Key Contract Terms", systemImage: "doc.text.fill")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                ForEach(analysis.keyTerms) { term in
                                    HStack {
                                        Image(systemName: term.status.icon)
                                            .foregroundColor(term.status.color)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(term.term)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            Text(term.value)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color(hex: "1C1C1E"))
                                    .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color(hex: "1C1C1E").opacity(0.5))
                            .cornerRadius(12)
                        }
                        
                        // Green Flags
                        if !analysis.greenFlags.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Positive Aspects", systemImage: "checkmark.circle.fill")
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "32D74B"))
                                
                                ForEach(analysis.greenFlags, id: \.self) { flag in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(Color(hex: "32D74B"))
                                            .font(.caption)
                                        Text(flag)
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(hex: "32D74B").opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        // Red Flags
                        if !analysis.redFlags.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Red Flags", systemImage: "exclamationmark.triangle.fill")
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "FF453A"))
                                
                                ForEach(analysis.redFlags) { flag in
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: flag.severity.icon)
                                            .foregroundColor(flag.severity.color)
                                            .font(.title3)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(flag.issue)
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                
                                                Spacer()
                                                
                                                Text(String(describing: flag.severity).uppercased())
                                                    .font(.caption2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(flag.severity.color)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(flag.severity.color.opacity(0.2))
                                                    .cornerRadius(4)
                                            }
                                            
                                            Text(flag.description)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding()
                                    .background(Color(hex: "FF453A").opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color(hex: "1C1C1E"))
                            .cornerRadius(12)
                        }
                        
                        // Recommendations
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Recommendations", systemImage: "lightbulb.fill")
                                .font(.headline)
                                .foregroundColor(Color(hex: "FFD60A"))
                            
                            ForEach(Array(analysis.recommendations.enumerated()), id: \.offset) { index, recommendation in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(hex: "FFD60A"))
                                        .frame(width: 24, height: 24)
                                        .background(Color(hex: "FFD60A").opacity(0.2))
                                        .cornerRadius(12)
                                    
                                    Text(recommendation)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color(hex: "FFD60A").opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color(hex: "1C1C1E"))
                        .cornerRadius(12)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                selectedScenario = nil
                            }) {
                                Text("Try Another Scenario")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(hex: "64D2FF"))
                                    .cornerRadius(12)
                            }
                            
                            Button(action: {}) {
                                HStack {
                                    Text("Request Beta Access")
                                    Image(systemName: "arrow.right")
                                }
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "32D74B"))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func scoreColor(_ score: Double) -> Color {
        switch score {
        case 8...10: return Color(hex: "32D74B") // Excellent - Green
        case 6..<8: return Color(hex: "FFD60A")  // Good - Yellow
        case 4..<6: return Color(hex: "FF9F0A")  // Fair - Orange
        default: return Color(hex: "FF453A")      // Poor - Red
        }
    }
}

struct FeatureItem: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(8)
    }
}

struct RedFlagItem: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(hex: "FF453A").opacity(0.1))
        .cornerRadius(8)
    }
}

struct RecommendationItem: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(hex: "FFD60A").opacity(0.1))
        .cornerRadius(8)
    }
}
