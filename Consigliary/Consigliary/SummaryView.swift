import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var appData: AppData
    @State private var showingContractAnalyzer = false
    @State private var showingSplitSheet = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        ScrollView {
                VStack(spacing: 24) {
                    // 24/7 Monitoring Badge
                    HStack {
                        Circle()
                            .fill(Color(hex: "32D74B"))
                            .frame(width: 12, height: 12)
                        Text("24/7 Active Monitoring")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding()
                    .background(Color(hex: "1C1C1E"))
                    .cornerRadius(12)
                    
                    // Autonomous Operations
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Autonomous Operations")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 16) {
                            MonitoringStatCard(
                                icon: "shield.checkmark.fill",
                                title: "Threats Neutralized",
                                value: "\(appData.threatsNeutralized)",
                                color: Color(hex: "32D74B")
                            )
                            
                            MonitoringStatCard(
                                icon: "eye.fill",
                                title: "Tracks Scanned",
                                value: appData.tracksScanned,
                                color: Color(hex: "64D2FF")
                            )
                        }
                        
                        HStack(spacing: 16) {
                            MonitoringStatCard(
                                icon: "clock.fill",
                                title: "Avg Response",
                                value: appData.averageResponseTime,
                                color: Color(hex: "FFD60A")
                            )
                            
                            MonitoringStatCard(
                                icon: "hand.raised.fill",
                                title: "Manual Review",
                                value: "\(appData.manualReviewCount)",
                                color: Color(hex: "FF9F0A")
                            )
                        }
                    }
                    
                    // Deal Scout
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Deal Scout")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            ForEach(appData.deals.filter { $0.status == .new || $0.status == .pending }) { deal in
                                DealCard(
                                    deal: deal,
                                    onAccept: { appData.acceptDeal(deal) },
                                    onDecline: { appData.declineDeal(deal) }
                                )
                            }
                            
                            if appData.deals.filter({ $0.status == .new || $0.status == .pending }).isEmpty {
                                Text("No active deals at the moment")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(hex: "1C1C1E"))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Actions")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        let columns = horizontalSizeClass == .regular ? 
                            [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] :
                            [GridItem(.flexible()), GridItem(.flexible())]
                        
                        LazyVGrid(columns: columns, spacing: 12) {
                            NavigationLink(destination: SplitSheetView()) {
                                ActionButton(
                                    icon: "doc.text.fill",
                                    title: "Split Sheet",
                                    color: Color(hex: "32D74B")
                                )
                            }
                            
                            NavigationLink(destination: ContractAnalyzerView()) {
                                ActionButton(
                                    icon: "doc.text.magnifyingglass",
                                    title: "Analyze Contract",
                                    color: Color(hex: "64D2FF")
                                )
                            }
                            
                            NavigationLink(destination: LicenseAgreementView()) {
                                ActionButton(
                                    icon: "doc.badge.gearshape",
                                    title: "License Agreement",
                                    color: Color(hex: "FFD60A")
                                )
                            }
                            
                            NavigationLink(destination: MyTracksView()) {
                                ActionButton(
                                    icon: "music.note.list",
                                    title: "My Tracks",
                                    color: Color(hex: "BF5AF2")
                                )
                            }
                        }
                    }
                    
                    // Revenue Summary
                    VStack(alignment: .leading, spacing: 16) {
                        Text("This Month")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        // Total Revenue Card
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Total Revenue")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text("$\(Int(appData.totalRevenue))")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(Color(hex: "32D74B"))
                                
                                Text("\(appData.revenueEvents.count) revenue events")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(hex: "1C1C1E"))
                        .cornerRadius(12)
                        
                        HStack(spacing: 16) {
                            RevenueCard(
                                icon: "music.note",
                                title: "Streaming",
                                value: "$\(Int(appData.streamingRevenue))",
                                subtitle: "\(Int((appData.streamingRevenue / appData.totalRevenue) * 100))% of total"
                            )
                            
                            RevenueCard(
                                icon: "dollarsign.circle.fill",
                                title: "Licensing",
                                value: "$\(Int(appData.syncRevenue))",
                                subtitle: appData.topTracks.first.map { "Top: \"\($0.title)\"" } ?? ""
                            )
                        }
                    }
                }
                .padding()
            }
            .background(Color.black)
            .frame(maxWidth: horizontalSizeClass == .regular ? 1000 : .infinity)
            .frame(maxWidth: .infinity)
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.large)
    }
}

struct MonitoringStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(12)
    }
}

struct DealCard: View {
    let deal: Deal
    let onAccept: () -> Void
    let onDecline: () -> Void
    @State private var showingAcceptAlert = false
    @State private var showingDeclineAlert = false
    
    var statusColor: Color {
        switch deal.status {
        case .new: return Color(hex: "32D74B")
        case .pending: return Color(hex: "FFD60A")
        case .accepted: return Color(hex: "64D2FF")
        case .declined: return .gray
        }
    }
    
    var statusText: String {
        switch deal.status {
        case .new: return "New"
        case .pending: return "Pending"
        case .accepted: return "Accepted"
        case .declined: return "Declined"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(deal.title)
                    .font(.headline)
                Spacer()
                Text(statusText)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .cornerRadius(6)
            }
            
            Text(deal.description)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(deal.value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "32D74B"))
            
            // Action buttons for new/pending deals
            if deal.status == .new || deal.status == .pending {
                HStack(spacing: 8) {
                    Button(action: {
                        let notification = UINotificationFeedbackGenerator()
                        notification.notificationOccurred(.success)
                        onAccept()
                        showingAcceptAlert = true
                    }) {
                        Text("Accept")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(hex: "32D74B"))
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        onDecline()
                        showingDeclineAlert = true
                    }) {
                        Text("Decline")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                    }
                }
                .alert("Deal Accepted!", isPresented: $showingAcceptAlert) {
                    Button("OK") { }
                } message: {
                    if let value = deal.monetaryValue {
                        Text("$\(Int(value)) added to your revenue. The deal has been accepted and will be processed.")
                    } else {
                        Text("Deal accepted! This opportunity has been added to your portfolio.")
                    }
                }
                .alert("Deal Declined", isPresented: $showingDeclineAlert) {
                    Button("OK") { }
                } message: {
                    Text("You've declined this opportunity. It will be removed from your deal list.")
                }
            }
        }
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(12)
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(12)
    }
}

struct RevenueCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "32D74B"))
                .font(.title2)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(12)
    }
}
