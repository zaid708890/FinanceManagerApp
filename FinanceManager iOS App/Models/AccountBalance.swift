import Foundation

// Transaction types for account tracking
enum TransactionType: String, Codable, CaseIterable {
    case salaryPayment = "Salary Payment"
    case expensePayment = "Expense Payment"
    case companyReimbursement = "Company Reimbursement"
    case personalDeposit = "Personal Deposit"
    case other = "Other"
}

// Status of the transaction
enum TransactionStatus: String, Codable, CaseIterable {
    case completed = "Completed"
    case pending = "Pending"  // Not yet reimbursed
    case failed = "Failed"
    case reimbursed = "Reimbursed"  // Reimbursed by company
    case cancelled = "Cancelled"  // Cancelled transaction
}

// Model for tracking account transactions
struct AccountTransaction: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var amount: Double  // Positive: paid out, Negative: received
    var description: String
    var type: TransactionType
    var relatedExpenseID: UUID?  // Link to related expense if any
    var relatedEmployeeID: UUID?  // Link to related employee if salary
    var status: TransactionStatus = .pending
    var reimbursementDate: Date?
    var paymentMethod: PaymentMethod?
    var referenceNumber: String?
    var notes: String?
    
    // Computed property for formatting
    var formattedAmount: String {
        return Formatters.formatCurrency(amount)
    }
    
    var formattedDate: String {
        return Formatters.formatDate(date)
    }
    
    var statusColor: Color {
        switch status {
        case .pending:
            return .yellow
        case .reimbursed:
            return .green
        case .cancelled:
            return .red
        case .completed:
            return .green
        case .failed:
            return .red
        }
    }
}

// Model for account summary
struct AccountBalance: Identifiable, Codable {
    var id = UUID()
    var ownerName: String
    var accountHolder: String
    var bankName: String
    var accountNumber: String
    var transactions: [AccountTransaction] = []
    var lastUpdated: Date = Date()
    
    // Computed properties
    var totalBalance: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }
    
    var pendingAmount: Double {
        return transactions.filter { $0.status == .pending && $0.type == .expensePayment }.reduce(0) { $0 + $1.amount }
    }
    
    var reimbursedAmount: Double {
        return transactions.filter { $0.type == .companyReimbursement }.reduce(0) { $0 + abs($1.amount) }
    }
    
    // Formatted properties for UI display
    var formattedTotalBalance: String {
        return Formatters.formatCurrency(totalBalance)
    }
    
    var formattedPendingAmount: String {
        return Formatters.formatCurrency(pendingAmount)
    }
    
    var formattedReimbursedAmount: String {
        return Formatters.formatCurrency(reimbursedAmount)
    }
    
    // Add a new transaction to the account
    mutating func addTransaction(_ transaction: AccountTransaction) {
        transactions.append(transaction)
        lastUpdated = Date()
    }
    
    // Update a transaction's status
    mutating func updateTransactionStatus(id: UUID, status: TransactionStatus, reimbursementDate: Date? = nil) {
        if let index = transactions.firstIndex(where: { $0.id == id }) {
            var transaction = transactions[index]
            transaction.status = status
            transaction.reimbursementDate = reimbursementDate
            transactions[index] = transaction
            lastUpdated = Date()
        }
    }
}

// Extension to Color for SwiftUI
import SwiftUI
extension Color {
    static let yellow = Color(UIColor.systemYellow)
    static let green = Color(UIColor.systemGreen)
    static let red = Color(UIColor.systemRed)
} 