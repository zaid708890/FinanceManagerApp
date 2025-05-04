import Foundation
import SwiftUI

struct FinancialMetric {
    let label: String
    let value: Double
    let color: Color
}

struct MonthlyData {
    let month: Date
    let income: Double
    let expenses: Double
    
    var profit: Double {
        return income - expenses
    }
}

class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {}
    
    // Calculate key performance indicators
    func calculateKPIs(dataManager: DataManager) -> [FinancialMetric] {
        let totalRevenue = calculateTotalRevenue(dataManager: dataManager)
        let totalExpenses = calculateTotalExpenses(dataManager: dataManager)
        let profit = totalRevenue - totalExpenses
        let profitMargin = totalRevenue > 0 ? (profit / totalRevenue) * 100 : 0
        
        let pendingPayments = calculatePendingPayments(dataManager: dataManager)
        let outstandingBalance = calculateOutstandingBalance(dataManager: dataManager)
        
        return [
            FinancialMetric(label: "Total Revenue", value: totalRevenue, color: .blue),
            FinancialMetric(label: "Total Expenses", value: totalExpenses, color: .red),
            FinancialMetric(label: "Profit", value: profit, color: .green),
            FinancialMetric(label: "Profit Margin", value: profitMargin, color: .purple),
            FinancialMetric(label: "Pending Payments", value: pendingPayments, color: .orange),
            FinancialMetric(label: "Outstanding Balance", value: outstandingBalance, color: .pink)
        ]
    }
    
    // Get monthly financial data for the past 12 months
    func getMonthlyFinancialData(dataManager: DataManager) -> [MonthlyData] {
        var monthlyData: [MonthlyData] = []
        
        // Get the date for 12 months ago
        let calendar = Calendar.current
        let currentDate = Date()
        guard let twelvemonthsAgo = calendar.date(byAdding: .month, value: -11, to: currentDate.startOfMonth) else {
            return []
        }
        
        var date = twelvemonthsAgo
        
        // Generate data for each month
        while date <= currentDate {
            let endOfMonth = date.endOfMonth
            
            // Calculate income (client payments) for this month
            let income = calculateMonthlyIncome(dataManager: dataManager, startDate: date, endDate: endOfMonth)
            
            // Calculate expenses for this month
            let expenses = calculateMonthlyExpenses(dataManager: dataManager, startDate: date, endDate: endOfMonth)
            
            monthlyData.append(MonthlyData(month: date, income: income, expenses: expenses))
            
            // Move to the next month
            if let nextMonth = calendar.date(byAdding: .month, value: 1, to: date) {
                date = nextMonth
            } else {
                break
            }
        }
        
        return monthlyData
    }
    
    // Get expense distribution by category
    func getExpenseDistribution(dataManager: DataManager) -> [FinancialMetric] {
        let categories = ExpenseCategory.allCases
        var expensesByCategory: [FinancialMetric] = []
        
        for category in categories {
            let total = dataManager.filteredExpenses
                .filter { $0.category == category }
                .reduce(0) { $0 + $1.amount }
            
            if total > 0 {
                expensesByCategory.append(FinancialMetric(
                    label: category.rawValue,
                    value: total,
                    color: getCategoryColor(category: category)
                ))
            }
        }
        
        // Sort by amount (highest first)
        return expensesByCategory.sorted { $0.value > $1.value }
    }
    
    // Get client revenue distribution
    func getClientRevenueDistribution(dataManager: DataManager) -> [FinancialMetric] {
        var revenueByClient: [FinancialMetric] = []
        
        // Calculate revenue for each client
        for (index, client) in dataManager.filteredClients.enumerated() {
            let revenue = client.projects.reduce(0) { total, project in
                total + project.payments.reduce(0) { $0 + $1.amount }
            }
            
            if revenue > 0 {
                revenueByClient.append(FinancialMetric(
                    label: client.name,
                    value: revenue,
                    color: getClientColor(index: index)
                ))
            }
        }
        
        // Sort by revenue (highest first)
        return revenueByClient.sorted { $0.value > $1.value }
    }
    
    // Private helper methods
    
    private func calculateTotalRevenue(dataManager: DataManager) -> Double {
        return dataManager.filteredClients.reduce(0) { total, client in
            total + client.projects.reduce(0) { projectTotal, project in
                projectTotal + project.payments.reduce(0) { $0 + $1.amount }
            }
        }
    }
    
    private func calculateTotalExpenses(dataManager: DataManager) -> Double {
        return dataManager.filteredExpenses.reduce(0) { $0 + $1.amount }
    }
    
    private func calculatePendingPayments(dataManager: DataManager) -> Double {
        return dataManager.filteredExpenses
            .filter { $0.status == .pending }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func calculateOutstandingBalance(dataManager: DataManager) -> Double {
        return dataManager.filteredClients.reduce(0) { $0 + $1.totalBalanceAmount }
    }
    
    private func calculateMonthlyIncome(dataManager: DataManager, startDate: Date, endDate: Date) -> Double {
        return dataManager.filteredClients.reduce(0) { clientTotal, client in
            clientTotal + client.projects.reduce(0) { projectTotal, project in
                projectTotal + project.payments.filter { 
                    $0.date >= startDate && $0.date <= endDate 
                }.reduce(0) { $0 + $1.amount }
            }
        }
    }
    
    private func calculateMonthlyExpenses(dataManager: DataManager, startDate: Date, endDate: Date) -> Double {
        return dataManager.filteredExpenses
            .filter { $0.date >= startDate && $0.date <= endDate }
            .reduce(0) { $0 + $1.amount }
    }
    
    // Helper functions for colors
    
    private func getCategoryColor(category: ExpenseCategory) -> Color {
        switch category {
        case .travel:
            return .blue
        case .accommodation:
            return .purple
        case .meals:
            return .orange
        case .equipment:
            return .red
        case .supplies:
            return .green
        case .transportation:
            return .yellow
        case .clientMeeting:
            return .pink
        case .marketing:
            return .teal
        case .software:
            return .indigo
        case .training:
            return .mint
        case .other:
            return .gray
        }
    }
    
    private func getClientColor(index: Int) -> Color {
        let colors: [Color] = [.blue, .green, .red, .orange, .purple, .pink, .yellow, .teal, .indigo, .mint]
        return colors[index % colors.count]
    }
}

// Add new colors for SwiftUI
extension Color {
    static let teal = Color(UIColor.systemTeal)
    static let indigo = Color(UIColor.systemIndigo)
    static let mint = Color(UIColor.systemMint)
} 