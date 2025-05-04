import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTimeRange: TimeRange = .year
    
    enum TimeRange: String, CaseIterable {
        case month = "Month"
        case quarter = "Quarter"
        case year = "Year"
    }
    
    var metrics: [FinancialMetric] {
        return AnalyticsManager.shared.calculateKPIs(dataManager: dataManager)
    }
    
    var monthlyData: [MonthlyData] {
        return AnalyticsManager.shared.getMonthlyFinancialData(dataManager: dataManager)
    }
    
    var expenseDistribution: [FinancialMetric] {
        return AnalyticsManager.shared.getExpenseDistribution(dataManager: dataManager)
    }
    
    var clientDistribution: [FinancialMetric] {
        return AnalyticsManager.shared.getClientDistribution(dataManager: dataManager)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Financial Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Welcome back, \(dataManager.employee.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Time Range Selector with modern style
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // KPI Cards
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(metrics.prefix(4), id: \.label) { metric in
                        KPICardView(metric: metric)
                    }
                }
                .padding(.horizontal)
                
                // Monthly Income/Expense Chart
                ChartCardView(title: "Monthly Overview", content: {
                    Chart {
                        ForEach(monthlyData, id: \.month) { data in
                            BarMark(
                                x: .value("Month", data.month, unit: .month),
                                y: .value("Income", data.income)
                            )
                            .foregroundStyle(Gradient(colors: [.blue, .cyan]))
                            .position(by: .value("Type", "Income"))
                            
                            BarMark(
                                x: .value("Month", data.month, unit: .month),
                                y: .value("Expenses", data.expenses)
                            )
                            .foregroundStyle(Gradient(colors: [.pink, .red]))
                            .position(by: .value("Type", "Expenses"))
                        }
                    }
                    .chartForegroundStyleScale([
                        "Income": Gradient(colors: [.blue, .cyan]),
                        "Expenses": Gradient(colors: [.pink, .red])
                    ])
                    .chartLegend(position: .top, alignment: .center)
                    .frame(height: 220)
                })
                
                // Quick Actions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Actions")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            QuickActionButton(
                                title: "Add Expense",
                                icon: "doc.text.fill",
                                color: .blue
                            ) {
                                // Action
                            }
                            
                            QuickActionButton(
                                title: "Pay Salary",
                                icon: "dollarsign.circle.fill",
                                color: .green
                            ) {
                                // Action
                            }
                            
                            QuickActionButton(
                                title: "Add Client",
                                icon: "person.2.fill",
                                color: .orange
                            ) {
                                // Action
                            }
                            
                            QuickActionButton(
                                title: "Reimbursement",
                                icon: "arrow.left.arrow.right.circle.fill",
                                color: .purple
                            ) {
                                // Action
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Distribution Charts
                HStack(spacing: 16) {
                    // Expense Pie Chart
                    PieChartCardView(
                        title: "Expenses by Category",
                        data: expenseDistribution
                    )
                    
                    // Client Pie Chart  
                    PieChartCardView(
                        title: "Revenue by Client",
                        data: clientDistribution
                    )
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Dashboard")
    }
}

// Stylish KPI Card
struct KPICardView: View {
    let metric: FinancialMetric
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(metric.label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(Formatters.formatCurrency(metric.value))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(metric.color)
            
            // Progress indicator or icon could go here
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
    }
}

// Stylish Card for Charts
struct ChartCardView<Content: View>: View {
    let title: String
    let content: () -> Content
    
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

// Stylish Quick Action Button
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
            }
        }
    }
}

// Stylish Pie Chart Card
struct PieChartCardView: View {
    let title: String
    let data: [FinancialMetric]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            // Pie chart visualization
            ZStack {
                ForEach(0..<data.count, id: \.self) { index in
                    PieSliceView(
                        startAngle: angle(for: index),
                        endAngle: angle(for: index + 1),
                        color: data[index].color
                    )
                }
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 50, height: 50)
            }
            .frame(height: 150)
            
            // Legend
            VStack(alignment: .leading, spacing: 8) {
                ForEach(data.prefix(3), id: \.label) { item in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 10, height: 10)
                        
                        Text(item.label)
                            .font(.caption)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("\(Int(item.value))")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
                
                if data.count > 3 {
                    Text("+ \(data.count - 3) more")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
        .frame(maxWidth: .infinity)
    }
    
    // Calculate angle for pie slices
    private func angle(for index: Int) -> Angle {
        let total = data.reduce(0) { $0 + $1.value }
        let sum = data[0..<min(index, data.count)].reduce(0) { $0 + $1.value }
        return .degrees(sum / total * 360)
    }
}

// Individual Pie Slice
struct PieSliceView: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius = min(geometry.size.width, geometry.size.height) / 2
                
                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false
                )
                path.closeSubpath()
            }
            .fill(color)
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DashboardView()
                .environmentObject(DataManager())
        }
    }
} 