import SwiftUI
import Charts

struct PersonalAccountDashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTimeRange: TimeRange = .month
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case quarter = "Quarter"
        case year = "Year"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Personal Finance")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    if let account = dataManager.personalAccount {
                        Text(account.ownerName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Time Range Selector
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Balance Card
                BalanceCard()
                    .padding(.horizontal)
                
                // In/Out Flow Chart
                ChartCardView(title: "Cash Flow") {
                    FinancialFlowChart(timeRange: selectedTimeRange)
                        .frame(height: 220)
                }
                
                // Quick Actions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Actions")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            QuickActionButton(
                                title: "Add Transaction",
                                icon: "plus.circle.fill",
                                color: .purple
                            ) {
                                // Action
                            }
                            
                            QuickActionButton(
                                title: "Record Reimbursement",
                                icon: "arrow.down.circle.fill",
                                color: .green
                            ) {
                                // Action
                            }
                            
                            QuickActionButton(
                                title: "Pending Requests",
                                icon: "clock.fill",
                                color: .orange
                            ) {
                                // Action
                            }
                            
                            QuickActionButton(
                                title: "Export Statement",
                                icon: "square.and.arrow.up.fill",
                                color: .blue
                            ) {
                                // Action
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Categories Breakdown
                CategoryBreakdownCard()
                    .padding(.horizontal)
                
                // Recent Transactions
                RecentTransactionsCard()
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("My Finances")
    }
}

// Balance Card
struct BalanceCard: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        VStack(spacing: 20) {
            // Total Balance
            HStack(alignment: .firstTextBaseline) {
                Text("Total Balance")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let account = dataManager.personalAccount {
                    Text(account.formattedTotalBalance)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(account.totalBalance < 0 ? .green : .red)
                }
            }
            
            Divider()
            
            // Pending vs Reimbursed
            HStack(alignment: .top, spacing: 0) {
                VStack(spacing: 8) {
                    Text("Pending")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let account = dataManager.personalAccount {
                        Text(account.formattedPendingAmount)
                            .font(.headline)
                            .foregroundColor(.orange)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 40)
                
                VStack(spacing: 8) {
                    Text("Reimbursed")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let account = dataManager.personalAccount {
                        Text(account.formattedReimbursedAmount)
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
    }
}

// Chart Card View
struct ChartCardView: View {
    let title: String
    let content: () -> some View
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
            
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
}

// Financial Flow Chart
struct FinancialFlowChart: View {
    @EnvironmentObject var dataManager: DataManager
    let timeRange: PersonalAccountDashboardView.TimeRange
    
    var monthlyData: [(month: Date, spent: Double, received: Double)] {
        guard let account = dataManager.personalAccount else { return [] }
        
        let calendar = Calendar.current
        let endDate = Date()
        
        var startDate: Date
        switch timeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: endDate) ?? endDate
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: endDate) ?? endDate
        case .quarter:
            startDate = calendar.date(byAdding: .month, value: -3, to: endDate) ?? endDate
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: endDate) ?? endDate
        }
        
        // Get transactions in range
        let filteredTransactions = dataManager.getPersonalAccountStatement(startDate: startDate, endDate: endDate)
        
        // Process data by month or week based on time range
        let groupingComponent: Calendar.Component = (timeRange == .week) ? .day : .month
        var resultsByDate: [Date: (spent: Double, received: Double)] = [:]
        
        for transaction in filteredTransactions {
            let dateComponents = calendar.dateComponents([.year, groupingComponent], from: transaction.date)
            guard let date = calendar.date(from: dateComponents) else { continue }
            
            var currentValues = resultsByDate[date] ?? (spent: 0, received: 0)
            
            if transaction.amount > 0 {
                // Money spent
                currentValues.spent += transaction.amount
            } else {
                // Money received
                currentValues.received += abs(transaction.amount)
            }
            
            resultsByDate[date] = currentValues
        }
        
        // Convert to array and sort by date
        return resultsByDate.map { ($0.key, $0.value.spent, $0.value.received) }
            .sorted { $0.0 < $1.0 }
    }
    
    var body: some View {
        if monthlyData.isEmpty {
            Text("No transaction data available for the selected period.")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
        } else {
            Chart {
                ForEach(monthlyData, id: \.month) { item in
                    BarMark(
                        x: .value("Date", item.month, unit: timeRange == .week ? .day : .month),
                        y: .value("Spent", item.spent)
                    )
                    .foregroundStyle(Gradient(colors: [.red, .orange]))
                    .position(by: .value("Type", "Spent"))
                    
                    BarMark(
                        x: .value("Date", item.month, unit: timeRange == .week ? .day : .month),
                        y: .value("Received", item.received)
                    )
                    .foregroundStyle(Gradient(colors: [.green, .mint]))
                    .position(by: .value("Type", "Received"))
                }
            }
            .chartForegroundStyleScale([
                "Spent": Gradient(colors: [.red, .orange]),
                "Received": Gradient(colors: [.green, .mint])
            ])
            .chartLegend(position: .top, alignment: .center)
        }
    }
}

// Quick Action Button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: 80)
            }
        }
    }
}

// Categories Breakdown Card
struct CategoryBreakdownCard: View {
    @EnvironmentObject var dataManager: DataManager
    
    var categories: [(type: TransactionType, amount: Double, color: Color)] {
        guard let account = dataManager.personalAccount else { return [] }
        
        var result: [TransactionType: Double] = [:]
        
        // Sum transactions by type
        for transaction in account.transactions where transaction.amount > 0 {
            result[transaction.type, default: 0] += transaction.amount
        }
        
        // Convert to array with colors
        return result.map { (type, amount) in
            let color: Color
            switch type {
            case .salaryPayment:
                color = .blue
            case .expensePayment:
                color = .red
            case .companyReimbursement:
                color = .green
            case .personalDeposit:
                color = .purple
            case .other:
                color = .gray
            }
            
            return (type, amount, color)
        }
        .sorted { $0.amount > $1.amount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Expenses by Category")
                .font(.headline)
            
            if categories.isEmpty {
                Text("No category data available.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                // Bar chart
                VStack(spacing: 12) {
                    ForEach(categories.prefix(5), id: \.type) { category in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(category.type.rawValue)
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text(Formatters.formatCurrency(category.amount))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            
                            // Progress bar
                            GeometryReader { geometry in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(category.color)
                                    .frame(width: calculateWidth(for: category.amount, totalWidth: geometry.size.width), height: 8)
                            }
                            .frame(height: 8)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
    }
    
    private func calculateWidth(for amount: Double, totalWidth: CGFloat) -> CGFloat {
        let maxAmount = categories.first?.amount ?? 1
        return CGFloat(amount / maxAmount) * totalWidth
    }
}

// Recent Transactions Card
struct RecentTransactionsCard: View {
    @EnvironmentObject var dataManager: DataManager
    
    var recentTransactions: [AccountTransaction] {
        guard let account = dataManager.personalAccount else { return [] }
        
        return Array(account.transactions
            .sorted(by: { $0.date > $1.date })
            .prefix(5))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: PersonalAccountView()) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            if recentTransactions.isEmpty {
                Text("No recent transactions.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(recentTransactions) { transaction in
                    HStack {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(getTransactionColor(for: transaction.type).opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: getTransactionIcon(for: transaction.type))
                                .foregroundColor(getTransactionColor(for: transaction.type))
                        }
                        
                        // Details
                        VStack(alignment: .leading, spacing: 4) {
                            Text(transaction.description)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            
                            Text(Formatters.formatDate(transaction.date))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Amount
                        Text(transaction.formattedAmount)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(transaction.amount > 0 ? .red : .green)
                    }
                    .padding(.vertical, 4)
                    
                    if transaction.id != recentTransactions.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
    }
    
    private func getTransactionColor(for type: TransactionType) -> Color {
        switch type {
        case .salaryPayment:
            return .blue
        case .expensePayment:
            return .red
        case .companyReimbursement:
            return .green
        case .personalDeposit:
            return .purple
        case .other:
            return .gray
        }
    }
    
    private func getTransactionIcon(for type: TransactionType) -> String {
        switch type {
        case .salaryPayment:
            return "dollarsign.circle.fill"
        case .expensePayment:
            return "cart.fill"
        case .companyReimbursement:
            return "arrow.left.arrow.right.circle.fill"
        case .personalDeposit:
            return "creditcard.fill"
        case .other:
            return "questionmark.circle.fill"
        }
    }
}

struct PersonalAccountDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PersonalAccountDashboardView()
                .environmentObject(DataManager())
        }
    }
} 