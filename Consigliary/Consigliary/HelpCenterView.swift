import SwiftUI

struct HelpCenterView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var searchText = ""
    @State private var selectedCategory: HelpCategory?
    
    let categories = HelpCategory.allCategories
    
    var filteredArticles: [HelpArticle] {
        if searchText.isEmpty {
            return HelpArticle.allArticles
        }
        return HelpArticle.allArticles.filter { article in
            article.title.localizedCaseInsensitiveContains(searchText) ||
            article.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ScrollView {
                VStack(spacing: 24) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search help articles", text: $searchText)
                            .foregroundColor(.white)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color(hex: "1C1C1E"))
                    .cornerRadius(12)
                    
                    // Categories
                    if searchText.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Browse by Category")
                                .font(.system(size: 20, weight: .bold))
                            
                            let columns = horizontalSizeClass == .regular ?
                                [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] :
                                [GridItem(.flexible()), GridItem(.flexible())]
                            
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(categories) { category in
                                    NavigationLink(destination: CategoryDetailView(category: category)) {
                                        CategoryCard(category: category)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Articles
                    VStack(alignment: .leading, spacing: 16) {
                        Text(searchText.isEmpty ? "Popular Articles" : "Search Results")
                            .font(.system(size: 20, weight: .bold))
                        
                        if filteredArticles.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray)
                                
                                Text("No articles found")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Text("Try adjusting your search terms")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                        } else {
                            ForEach(filteredArticles) { article in
                                NavigationLink(destination: ArticleDetailView(article: article)) {
                                    ArticleRow(article: article)
                                }
                            }
                        }
                    }
                    
                    // Contact Support
                    VStack(spacing: 16) {
                        Divider()
                            .background(Color.gray.opacity(0.3))
                        
                        VStack(spacing: 12) {
                            Text("Still need help?")
                                .font(.headline)
                            
                            NavigationLink(destination: ContactUsView()) {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                    Text("Contact Support")
                                }
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "32D74B"))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.black)
            .navigationTitle("Help Center")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
    }
}

struct CategoryCard: View {
    let category: HelpCategory
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.system(size: 32))
                .foregroundColor(category.color)
            
            Text(category.name)
                .font(.system(size: 15, weight: .semibold))
                .multilineTextAlignment(.center)
            
            Text("\(category.articleCount) articles")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(12)
    }
}

struct ArticleRow: View {
    let article: HelpArticle
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: article.icon)
                .foregroundColor(Color(hex: "64D2FF"))
                .font(.title3)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(article.category)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(12)
    }
}

struct CategoryDetailView: View {
    @Environment(\.dismiss) var dismiss
    let category: HelpCategory
    
    var categoryArticles: [HelpArticle] {
        HelpArticle.allArticles.filter { $0.category == category.name }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(categoryArticles) { article in
                    NavigationLink(destination: ArticleDetailView(article: article)) {
                        ArticleRow(article: article)
                    }
                }
            }
            .padding()
        }
        .background(Color.black)
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ArticleDetailView: View {
    @Environment(\.dismiss) var dismiss
    let article: HelpArticle
    @State private var wasHelpful: Bool?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Article Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(article.category)
                        .font(.caption)
                        .foregroundColor(Color(hex: "64D2FF"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "64D2FF").opacity(0.2))
                        .cornerRadius(6)
                    
                    Text(article.title)
                        .font(.system(size: 22, weight: .bold))
                }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // Article Content
                Text(article.content)
                    .font(.body)
                    .foregroundColor(.white)
                    .lineSpacing(6)
                
                // Steps if available
                if !article.steps.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Steps")
                            .font(.headline)
                        
                        ForEach(Array(article.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(width: 24, height: 24)
                                    .background(Color(hex: "32D74B"))
                                    .cornerRadius(12)
                                
                                Text(step)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding()
                    .background(Color(hex: "1C1C1E"))
                    .cornerRadius(12)
                }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // Feedback Section
                VStack(spacing: 16) {
                    Text("Was this article helpful?")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            wasHelpful = true
                        }) {
                            HStack {
                                Image(systemName: wasHelpful == true ? "hand.thumbsup.fill" : "hand.thumbsup")
                                Text("Yes")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(wasHelpful == true ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(wasHelpful == true ? Color(hex: "32D74B") : Color(hex: "1C1C1E"))
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            wasHelpful = false
                        }) {
                            HStack {
                                Image(systemName: wasHelpful == false ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                Text("No")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(wasHelpful == false ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(wasHelpful == false ? Color(hex: "FF453A") : Color(hex: "1C1C1E"))
                            .cornerRadius(12)
                        }
                    }
                    
                    if wasHelpful != nil {
                        Text(wasHelpful == true ? "Thanks for your feedback!" : "We're sorry this didn't help. Please contact support for more assistance.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding()
        }
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HelpCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let articleCount: Int
    
    static let allCategories = [
        HelpCategory(name: "Getting Started", icon: "star.fill", color: Color(hex: "FFD60A"), articleCount: 5),
        HelpCategory(name: "Rights Monitoring", icon: "eye.fill", color: Color(hex: "64D2FF"), articleCount: 8),
        HelpCategory(name: "Contract Analysis", icon: "doc.text.magnifyingglass", color: Color(hex: "32D74B"), articleCount: 6),
        HelpCategory(name: "Revenue & Billing", icon: "dollarsign.circle.fill", color: Color(hex: "32D74B"), articleCount: 7),
        HelpCategory(name: "Account & Settings", icon: "gearshape.fill", color: Color.gray, articleCount: 4),
        HelpCategory(name: "Troubleshooting", icon: "exclamationmark.triangle.fill", color: Color(hex: "FF453A"), articleCount: 5)
    ]
}

struct HelpArticle: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let icon: String
    let content: String
    let steps: [String]
    
    static let allArticles = [
        HelpArticle(
            title: "How to set up your account",
            category: "Getting Started",
            icon: "person.circle.fill",
            content: "Setting up your Consigliary account is quick and easy. Follow these steps to get started with protecting your music rights.",
            steps: [
                "Download the Consigliary app from the App Store",
                "Open the app and tap 'Get Started'",
                "Complete the onboarding flow",
                "Add your profile information and music catalog",
                "Enable notifications to stay informed"
            ]
        ),
        HelpArticle(
            title: "Understanding rights monitoring",
            category: "Rights Monitoring",
            icon: "eye.fill",
            content: "Consigliary monitors over 2.3 million tracks daily across major platforms including TikTok, Instagram, YouTube, and more. Our AI-powered system detects unauthorized use of your music in real-time and alerts you immediately so you can take action.",
            steps: []
        ),
        HelpArticle(
            title: "How to respond to unauthorized use",
            category: "Rights Monitoring",
            icon: "shield.fill",
            content: "When unauthorized use is detected, you have three options: issue a takedown, offer a license, or ignore. Each option has different implications for your rights and revenue.",
            steps: [
                "Review the unauthorized use notification",
                "Choose your response: Takedown, License, or Ignore",
                "If licensing, set your fee and generate the agreement",
                "Track the outcome in your activity feed"
            ]
        ),
        HelpArticle(
            title: "Analyzing contracts with AI",
            category: "Contract Analysis",
            icon: "doc.text.magnifyingglass",
            content: "Our AI contract analyzer reviews music industry contracts and provides a fairness score, identifies red flags, and offers recommendations. Upload any PDF or image of your contract to get started.",
            steps: [
                "Navigate to Contract Analyzer",
                "Upload your contract (PDF, DOC, or image)",
                "Wait for AI analysis (usually under 30 seconds)",
                "Review the fairness score and red flags",
                "Read recommendations before signing"
            ]
        ),
        HelpArticle(
            title: "Creating split sheets",
            category: "Getting Started",
            icon: "doc.text.fill",
            content: "Split sheets document ownership percentages for collaborative works. Consigliary makes it easy to create professional split sheets that all collaborators can sign.",
            steps: [
                "Go to Summary and tap 'Split Sheet'",
                "Enter the track title",
                "Add all contributors with their roles",
                "Adjust ownership percentages (must total 100%)",
                "Generate and share the PDF"
            ]
        ),
        HelpArticle(
            title: "Understanding your revenue dashboard",
            category: "Revenue & Billing",
            icon: "chart.bar.fill",
            content: "Your revenue dashboard shows all income from streaming, licensing, and performance rights. Track your top-performing tracks and see detailed breakdowns of each revenue stream.",
            steps: []
        ),
        HelpArticle(
            title: "Managing notification preferences",
            category: "Account & Settings",
            icon: "bell.fill",
            content: "Customize which notifications you receive and how you receive them. You can enable or disable push notifications, email alerts, and choose which types of events trigger notifications.",
            steps: [
                "Go to Account tab",
                "Tap 'Notifications'",
                "Toggle notification types on or off",
                "Save your preferences"
            ]
        ),
        HelpArticle(
            title: "What to do if monitoring isn't working",
            category: "Troubleshooting",
            icon: "exclamationmark.triangle.fill",
            content: "If you're not seeing monitoring results, first check that you've added your tracks to your catalog and that monitoring is enabled. If issues persist, contact support.",
            steps: [
                "Verify your tracks are in your catalog",
                "Check that 24/7 monitoring is enabled",
                "Ensure you have an active subscription",
                "Try logging out and back in",
                "Contact support if issues continue"
            ]
        )
    ]
}
