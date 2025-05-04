import Foundation
import UIKit
import PDFKit

class PDFGenerator {
    
    // Generate PDF for client statement
    static func generateClientStatementPDF(statement: ClientStatement) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Finance Manager App",
            kCGPDFContextAuthor: "Generated automatically"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            // Draw header
            let titleFont = UIFont.boldSystemFont(ofSize: 24.0)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont
            ]
            
            let header = "Client Statement"
            let headerSize = header.size(withAttributes: titleAttributes)
            let headerRect = CGRect(
                x: (pageRect.width - headerSize.width) / 2.0,
                y: 50,
                width: headerSize.width,
                height: headerSize.height
            )
            header.draw(in: headerRect, withAttributes: titleAttributes)
            
            // Draw client info
            let normalFont = UIFont.systemFont(ofSize: 12.0)
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .font: normalFont
            ]
            
            let clientInfo = """
            Client: \(statement.clientName)
            Company: \(statement.company)
            Period: \(statement.period.formattedString)
            Generated Date: \(Formatters.formatDate(statement.generatedDate))
            """
            
            let clientInfoRect = CGRect(x: 50, y: 100, width: pageRect.width - 100, height: 100)
            clientInfo.draw(in: clientInfoRect, withAttributes: normalAttributes)
            
            // Draw summary
            let summaryInfo = """
            
            Summary:
            Total Amount: \(Formatters.formatCurrency(statement.totalAmount))
            Total Paid: \(Formatters.formatCurrency(statement.totalPaid))
            Balance Due: \(Formatters.formatCurrency(statement.balanceDue))
            """
            
            let summaryInfoRect = CGRect(x: 50, y: 200, width: pageRect.width - 100, height: 100)
            summaryInfo.draw(in: summaryInfoRect, withAttributes: normalAttributes)
            
            // Draw project details
            var yPosition = 320.0
            
            for (index, project) in statement.projectPayments.enumerated() {
                let projectTitle = "Project \(index + 1): \(project.projectName)"
                let projectTitleFont = UIFont.boldSystemFont(ofSize: 14.0)
                let projectTitleAttributes: [NSAttributedString.Key: Any] = [
                    .font: projectTitleFont
                ]
                
                let projectTitleRect = CGRect(x: 50, y: yPosition, width: pageRect.width - 100, height: 20)
                projectTitle.draw(in: projectTitleRect, withAttributes: projectTitleAttributes)
                
                yPosition += 25
                
                let projectDetails = """
                Contract Amount: \(Formatters.formatCurrency(project.contractAmount))
                Paid Amount: \(Formatters.formatCurrency(project.paidAmount))
                Balance: \(Formatters.formatCurrency(project.balance))
                
                Payments:
                """
                
                let projectDetailsRect = CGRect(x: 60, y: yPosition, width: pageRect.width - 120, height: 100)
                projectDetails.draw(in: projectDetailsRect, withAttributes: normalAttributes)
                
                yPosition += 80
                
                for payment in project.payments {
                    let paymentDetails = "• \(Formatters.formatDate(payment.date)): \(Formatters.formatCurrency(payment.amount)) (\(payment.type))"
                    let paymentDetailsRect = CGRect(x: 70, y: yPosition, width: pageRect.width - 140, height: 20)
                    paymentDetails.draw(in: paymentDetailsRect, withAttributes: normalAttributes)
                    
                    yPosition += 20
                }
                
                yPosition += 20
            }
            
            // Draw footer
            let footer = "Thank you for your business!"
            let footerRect = CGRect(
                x: 50,
                y: pageRect.height - 50,
                width: pageRect.width - 100,
                height: 20
            )
            footer.draw(in: footerRect, withAttributes: normalAttributes)
        }
        
        return data
    }
    
    // Generate PDF for salary slip
    static func generateSalarySlipPDF(salarySlip: SalarySlip) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Finance Manager App",
            kCGPDFContextAuthor: "Generated automatically"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            // Draw header
            let titleFont = UIFont.boldSystemFont(ofSize: 24.0)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont
            ]
            
            let header = "Salary Slip"
            let headerSize = header.size(withAttributes: titleAttributes)
            let headerRect = CGRect(
                x: (pageRect.width - headerSize.width) / 2.0,
                y: 50,
                width: headerSize.width,
                height: headerSize.height
            )
            header.draw(in: headerRect, withAttributes: titleAttributes)
            
            // Draw employee info
            let normalFont = UIFont.systemFont(ofSize: 12.0)
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .font: normalFont
            ]
            
            let employeeInfo = """
            Employee: \(salarySlip.employeeName)
            Position: \(salarySlip.position)
            Period: \(salarySlip.period.formattedString)
            """
            
            let employeeInfoRect = CGRect(x: 50, y: 100, width: pageRect.width - 100, height: 100)
            employeeInfo.draw(in: employeeInfoRect, withAttributes: normalAttributes)
            
            // Draw salary details
            let salaryDetails = """
            
            Salary Details:
            Base Salary: \(Formatters.formatCurrency(salarySlip.baseSalary))
            Bonuses: \(Formatters.formatCurrency(salarySlip.bonuses))
            Deductions: \(Formatters.formatCurrency(salarySlip.deductions))
            Advances: \(Formatters.formatCurrency(salarySlip.advances))
            
            Total Earnings: \(Formatters.formatCurrency(salarySlip.totalEarnings))
            Total Deductions: \(Formatters.formatCurrency(salarySlip.totalDeductions))
            Net Salary: \(Formatters.formatCurrency(salarySlip.netSalary))
            """
            
            let salaryDetailsRect = CGRect(x: 50, y: 200, width: pageRect.width - 100, height: 200)
            salaryDetails.draw(in: salaryDetailsRect, withAttributes: normalAttributes)
            
            // Draw payment info if available
            var paymentInfo = "\nPayment Information:"
            
            if let method = salarySlip.paymentMethod {
                paymentInfo += "\nPayment Method: \(method)"
            }
            
            if let date = salarySlip.paymentDate {
                paymentInfo += "\nPayment Date: \(Formatters.formatDate(date))"
            }
            
            if let reference = salarySlip.referenceNumber {
                paymentInfo += "\nReference Number: \(reference)"
            }
            
            if let processor = salarySlip.processedBy {
                paymentInfo += "\nProcessed By: \(processor)"
            }
            
            let paymentInfoRect = CGRect(x: 50, y: 400, width: pageRect.width - 100, height: 150)
            paymentInfo.draw(in: paymentInfoRect, withAttributes: normalAttributes)
            
            // Draw notes if available
            if let notes = salarySlip.notes {
                let notesText = "\nNotes:\n\(notes)"
                let notesRect = CGRect(x: 50, y: 550, width: pageRect.width - 100, height: 100)
                notesText.draw(in: notesRect, withAttributes: normalAttributes)
            }
            
            // Draw footer
            let footer = "Generated on \(Formatters.formatDate(salarySlip.generatedDate))"
            let footerRect = CGRect(
                x: 50,
                y: pageRect.height - 50,
                width: pageRect.width - 100,
                height: 20
            )
            footer.draw(in: footerRect, withAttributes: normalAttributes)
        }
        
        return data
    }
    
    // Generate PDF for expense report
    static func generateExpenseReportPDF(report: ExpenseReport, expenses: [CompanyExpense]) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Finance Manager App",
            kCGPDFContextAuthor: "Generated automatically"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            // Draw header
            let titleFont = UIFont.boldSystemFont(ofSize: 24.0)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont
            ]
            
            let header = "Expense Report"
            let headerSize = header.size(withAttributes: titleAttributes)
            let headerRect = CGRect(
                x: (pageRect.width - headerSize.width) / 2.0,
                y: 50,
                width: headerSize.width,
                height: headerSize.height
            )
            header.draw(in: headerRect, withAttributes: titleAttributes)
            
            // Draw report info
            let normalFont = UIFont.systemFont(ofSize: 12.0)
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .font: normalFont
            ]
            
            let reportInfo = """
            Title: \(report.title)
            Employee: \(report.employeeName)
            Period: \(report.period.formattedString)
            Submission Date: \(Formatters.formatDate(report.submissionDate))
            Status: \(report.status.rawValue)
            Total Amount: \(Formatters.formatCurrency(report.totalAmount))
            """
            
            let reportInfoRect = CGRect(x: 50, y: 100, width: pageRect.width - 100, height: 150)
            reportInfo.draw(in: reportInfoRect, withAttributes: normalAttributes)
            
            // Draw approval info if available
            var approvalInfo = ""
            
            if let approvedBy = report.approvedBy {
                approvalInfo += "\nApproved By: \(approvedBy)"
            }
            
            if let approvalDate = report.approvalDate {
                approvalInfo += "\nApproval Date: \(Formatters.formatDate(approvalDate))"
            }
            
            if let reimbursementDate = report.reimbursementDate {
                approvalInfo += "\nReimbursement Date: \(Formatters.formatDate(reimbursementDate))"
            }
            
            if let method = report.reimbursementMethod {
                approvalInfo += "\nReimbursement Method: \(method.rawValue)"
            }
            
            if let reference = report.reimbursementReferenceNumber {
                approvalInfo += "\nReference Number: \(reference)"
            }
            
            if !approvalInfo.isEmpty {
                let approvalInfoRect = CGRect(x: 50, y: 250, width: pageRect.width - 100, height: 150)
                approvalInfo.draw(in: approvalInfoRect, withAttributes: normalAttributes)
            }
            
            // Draw expense details
            let expenseHeaderFont = UIFont.boldSystemFont(ofSize: 14.0)
            let expenseHeaderAttributes: [NSAttributedString.Key: Any] = [
                .font: expenseHeaderFont
            ]
            
            let expenseHeader = "Expenses:"
            let expenseHeaderRect = CGRect(x: 50, y: 350, width: pageRect.width - 100, height: 20)
            expenseHeader.draw(in: expenseHeaderRect, withAttributes: expenseHeaderAttributes)
            
            var yPosition = 380.0
            
            for (index, expense) in expenses.enumerated() {
                let expenseDetails = """
                \(index + 1). \(expense.title) - \(expense.formattedAmount)
                   Date: \(expense.formattedDate)
                   Category: \(expense.category.rawValue)
                   Paid By: \(expense.paidBy)
                   Status: \(expense.status.rawValue)
                """
                
                let expenseDetailsRect = CGRect(x: 60, y: yPosition, width: pageRect.width - 120, height: 80)
                expenseDetails.draw(in: expenseDetailsRect, withAttributes: normalAttributes)
                
                yPosition += 90
                
                if yPosition > pageRect.height - 100 {
                    context.beginPage()
                    yPosition = 50
                }
            }
            
            // Draw notes if available
            if let notes = report.notes {
                if yPosition > pageRect.height - 150 {
                    context.beginPage()
                    yPosition = 50
                }
                
                let notesText = "Notes:\n\(notes)"
                let notesRect = CGRect(x: 50, y: yPosition, width: pageRect.width - 100, height: 100)
                notesText.draw(in: notesRect, withAttributes: normalAttributes)
            }
        }
        
        return data
    }
} 